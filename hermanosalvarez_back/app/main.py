from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session, aliased
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
def get_paradas(
    dia: str | None = None,
    db: Session = Depends(get_db),
):
    # Si no se especifica día, mantenemos el comportamiento anterior
    if dia is None:
        stops = db.query(Stop).all()

    else:
        OrigenRouteStop = aliased(RouteStop)
        DestinoRouteStop = aliased(RouteStop)

        HoraOrigen = aliased(TripStopTime)
        HoraDestino = aliased(TripStopTime)

        # Solo paradas desde las que realmente se puede iniciar
        # algún viaje ese día.
        stops = (
            db.query(Stop)
            .join(
                OrigenRouteStop,
                OrigenRouteStop.stop_id == Stop.id,
            )
            .join(
                DestinoRouteStop,
                and_(
                    DestinoRouteStop.route_id == OrigenRouteStop.route_id,
                    DestinoRouteStop.stop_order > OrigenRouteStop.stop_order,
                ),
            )
            .join(
                TripSchedule,
                and_(
                    TripSchedule.route_id == OrigenRouteStop.route_id,
                    TripSchedule.day_type == dia,
                ),
            )
            .join(
                HoraOrigen,
                and_(
                    HoraOrigen.trip_id == TripSchedule.id,
                    HoraOrigen.stop_id == OrigenRouteStop.stop_id,
                ),
            )
            .join(
                HoraDestino,
                and_(
                    HoraDestino.trip_id == TripSchedule.id,
                    HoraDestino.stop_id == DestinoRouteStop.stop_id,
                ),
            )
            .filter(
                HoraDestino.time_value > HoraOrigen.time_value,
            )
            .distinct()
            .all()
        )

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
def get_destinos_validos(
    origen: str,
    dia: str = "laborable",
    db: Session = Depends(get_db),
):
    OrigenRouteStop = aliased(RouteStop)
    DestinoRouteStop = aliased(RouteStop)

    HoraOrigen = aliased(TripStopTime)
    HoraDestino = aliased(TripStopTime)

    paradas = (
        db.query(Stop)
        .join(
            DestinoRouteStop,
            DestinoRouteStop.stop_id == Stop.id,
        )
        .join(
            OrigenRouteStop,
            and_(
                OrigenRouteStop.route_id == DestinoRouteStop.route_id,
                OrigenRouteStop.stop_id == origen,
                OrigenRouteStop.stop_order < DestinoRouteStop.stop_order,
            ),
        )
        .join(
            TripSchedule,
            and_(
                TripSchedule.route_id == OrigenRouteStop.route_id,
                TripSchedule.day_type == dia,
            ),
        )
        .join(
            HoraOrigen,
            and_(
                HoraOrigen.trip_id == TripSchedule.id,
                HoraOrigen.stop_id == origen,
            ),
        )
        .join(
            HoraDestino,
            and_(
                HoraDestino.trip_id == TripSchedule.id,
                HoraDestino.stop_id == DestinoRouteStop.stop_id,
            ),
        )
        .filter(
            HoraDestino.time_value > HoraOrigen.time_value,
        )
        .distinct()
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
def get_horarios(
    origen: str,
    destino: str,
    dia: str,
    db: Session = Depends(get_db),
):
    OrigenRouteStop = aliased(RouteStop)
    DestinoRouteStop = aliased(RouteStop)

    HoraOrigen = aliased(TripStopTime)
    HoraDestino = aliased(TripStopTime)

    viajes = (
        db.query(
            TripSchedule.route_id,
            HoraOrigen.time_value.label("salida"),
            HoraDestino.time_value.label("llegada"),
        )
        .join(
            OrigenRouteStop,
            and_(
                OrigenRouteStop.route_id == TripSchedule.route_id,
                OrigenRouteStop.stop_id == origen,
            ),
        )
        .join(
            DestinoRouteStop,
            and_(
                DestinoRouteStop.route_id == TripSchedule.route_id,
                DestinoRouteStop.stop_id == destino,
                DestinoRouteStop.stop_order > OrigenRouteStop.stop_order,
            ),
        )
        .join(
            HoraOrigen,
            and_(
                HoraOrigen.trip_id == TripSchedule.id,
                HoraOrigen.stop_id == origen,
            ),
        )
        .join(
            HoraDestino,
            and_(
                HoraDestino.trip_id == TripSchedule.id,
                HoraDestino.stop_id == destino,
            ),
        )
        .filter(
            TripSchedule.day_type == dia,
            HoraDestino.time_value > HoraOrigen.time_value,
        )
        .distinct()
        .all()
    )

    resultados = [
        {
            "ruta": viaje.route_id,
            "salida": viaje.salida,
            "llegada": viaje.llegada,
        }
        for viaje in viajes
    ]

    resultados.sort(key=lambda x: x["salida"])

    rutas = sorted({
        resultado["ruta"]
        for resultado in resultados
    })

    return {
        # Compatibilidad con la respuesta anterior
        "ruta": rutas[0] if len(rutas) == 1 else None,

        # Ahora podemos tener varias rutas
        "rutas": rutas,

        "horarios": resultados,
    }
