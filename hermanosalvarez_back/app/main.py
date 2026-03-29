from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import and_

from app.db import get_db
from app.models import Stop, Route, RouteStop, TripSchedule, TripStopTime

app = FastAPI(title="Autocares Hermanos Álvarez API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"mensaje": "API funcionando 🚀"}


@app.get("/paradas")
def get_paradas(db: Session = Depends(get_db)):
    stops = db.query(Stop).all()

    resultado = [
        {
            "id": stop.id,
            "nombre": stop.name,
            "bajoDemanda": stop.on_demand,
        }
        for stop in stops
    ]

    resultado.sort(key=lambda x: x["nombre"])
    return resultado


@app.get("/destinos-validos")
def get_destinos_validos(origen: str, dia: str = "laborable", db: Session = Depends(get_db)):
    # Rutas donde aparece el origen
    route_stops_origen = (
        db.query(RouteStop)
        .filter(RouteStop.stop_id == origen)
        .all()
    )

    destinos_validos = set()

    for origen_rs in route_stops_origen:
        # Paradas posteriores en la misma ruta
        siguientes_paradas = (
            db.query(RouteStop)
            .filter(
                RouteStop.route_id == origen_rs.route_id,
                RouteStop.stop_order > origen_rs.stop_order
            )
            .all()
        )

        if not siguientes_paradas:
            continue

        # Viajes de esa ruta y ese día
        trips = (
            db.query(TripSchedule)
            .filter(
                TripSchedule.route_id == origen_rs.route_id,
                TripSchedule.day_type == dia
            )
            .all()
        )

        for destino_rs in siguientes_paradas:
            for trip in trips:
                hora_origen = (
                    db.query(TripStopTime)
                    .filter(
                        TripStopTime.trip_id == trip.id,
                        TripStopTime.stop_id == origen
                    )
                    .first()
                )

                hora_destino = (
                    db.query(TripStopTime)
                    .filter(
                        TripStopTime.trip_id == trip.id,
                        TripStopTime.stop_id == destino_rs.stop_id
                    )
                    .first()
                )

                if hora_origen and hora_destino and hora_destino.time_value > hora_origen.time_value:
                    destinos_validos.add(destino_rs.stop_id)
                    break

    paradas = (
        db.query(Stop)
        .filter(Stop.id.in_(destinos_validos))
        .all()
    )

    resultado = [
        {
            "id": parada.id,
            "nombre": parada.name,
            "bajoDemanda": parada.on_demand,
        }
        for parada in paradas
    ]

    resultado.sort(key=lambda x: x["nombre"])
    return resultado


@app.get("/horarios")
def get_horarios(origen: str, destino: str, dia: str, db: Session = Depends(get_db)):
    # Buscar rutas donde origen y destino estén en orden correcto
    origen_rows = (
        db.query(RouteStop)
        .filter(RouteStop.stop_id == origen)
        .all()
    )

    ruta_encontrada = None

    for origen_rs in origen_rows:
        destino_rs = (
            db.query(RouteStop)
            .filter(
                RouteStop.route_id == origen_rs.route_id,
                RouteStop.stop_id == destino
            )
            .first()
        )

        if destino_rs and origen_rs.stop_order < destino_rs.stop_order:
            ruta_encontrada = origen_rs.route_id
            break

    if ruta_encontrada is None:
        return {"ruta": None, "horarios": []}

    trips = (
        db.query(TripSchedule)
        .filter(
            TripSchedule.route_id == ruta_encontrada,
            TripSchedule.day_type == dia
        )
        .all()
    )

    resultados = []

    for trip in trips:
        hora_origen = (
            db.query(TripStopTime)
            .filter(
                TripStopTime.trip_id == trip.id,
                TripStopTime.stop_id == origen
            )
            .first()
        )

        hora_destino = (
            db.query(TripStopTime)
            .filter(
                TripStopTime.trip_id == trip.id,
                TripStopTime.stop_id == destino
            )
            .first()
        )

        if hora_origen and hora_destino:
            resultados.append({
                "salida": hora_origen.time_value,
                "llegada": hora_destino.time_value
            })

    resultados.sort(key=lambda x: x["salida"])

    return {
        "ruta": ruta_encontrada,
        "horarios": resultados
    }
