from pathlib import Path
import json
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = Path(__file__).resolve().parent
DATA_FILE = BASE_DIR / "data" / "lineas.json"


def cargar_datos():
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


@app.get("/")
def root():
    return {"mensaje": "API funcionando 🚀"}


@app.get("/paradas")
def get_paradas():
    data = cargar_datos()
    paradas = data.get("paradas", {})

    resultado = [
        {
            "id": parada_id,
            "nombre": parada_info["nombre"],
            "bajoDemanda": parada_info["bajoDemanda"],
        }
        for parada_id, parada_info in paradas.items()
    ]

    resultado.sort(key=lambda x: x["nombre"])
    return resultado

@app.get("/destinos-validos")
def get_destinos_validos(origen: str, dia: str = "laborable"):
    data = cargar_datos()

    rutas = data.get("rutas", {})
    paradas = data.get("paradas", {})
    horarios_por_dia = data.get("horarios", {})
    horarios_dia = horarios_por_dia.get(dia, {})

    def hora_a_minutos(hora: str) -> int:
        h, m = hora.split(":")
        return int(h) * 60 + int(m)

    destinos_validos = set()

    for codigo_ruta, ruta in rutas.items():
        lista_paradas = ruta.get("paradas", [])

        if origen not in lista_paradas:
            continue

        index_origen = lista_paradas.index(origen)
        posibles_destinos = lista_paradas[index_origen + 1:]
        viajes = horarios_dia.get(codigo_ruta, [])

        for destino in posibles_destinos:
            for viaje in viajes:
                hora_origen = viaje.get(origen)
                hora_destino = viaje.get(destino)

                if hora_origen and hora_destino:
                    if hora_a_minutos(hora_destino) > hora_a_minutos(hora_origen):
                        destinos_validos.add(destino)
                        break

    resultado = [
        {
            "id": parada_id,
            "nombre": paradas[parada_id]["nombre"],
            "bajoDemanda": paradas[parada_id]["bajoDemanda"],
        }
        for parada_id in destinos_validos
        if parada_id in paradas
    ]

    resultado.sort(key=lambda x: x["nombre"])
    return resultado

@app.get("/horarios")
def get_horarios(origen: str, destino: str, dia: str):
    data = cargar_datos()

    rutas = data.get("rutas", {})
    horarios = data.get("horarios", {})

    # 1. Encontrar ruta válida
    ruta_encontrada = None

    for codigo, ruta in rutas.items():
        paradas = ruta.get("paradas", [])

        if origen in paradas and destino in paradas:
            if paradas.index(origen) < paradas.index(destino):
                ruta_encontrada = codigo
                break

    if ruta_encontrada is None:
        return {"horarios": []}

    # 2. Obtener horarios
    horarios_dia = horarios.get(dia, {})
    horarios_ruta = horarios_dia.get(ruta_encontrada, [])

    resultados = []

    for viaje in horarios_ruta:
        hora_origen = viaje.get(origen)
        hora_destino = viaje.get(destino)

        if hora_origen and hora_destino:
            resultados.append({
                "salida": hora_origen,
                "llegada": hora_destino
            })

    return {
        "ruta": ruta_encontrada,
        "horarios": resultados
    }