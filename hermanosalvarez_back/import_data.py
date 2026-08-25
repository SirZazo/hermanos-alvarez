import json
import os
from pathlib import Path

import psycopg2


def normalizar_hora(hora: str | None) -> str | None:
    if hora is None:
        return None

    hora = hora.strip()
    h, m = hora.split(":")

    h = int(h)
    m = int(m)

    if not 0 <= h <= 23:
        raise ValueError(f"Hora inválida: {hora}")

    if not 0 <= m <= 59:
        raise ValueError(f"Minutos inválidos: {hora}")

    return f"{h:02d}:{m:02d}"


def validar_datos(data: dict) -> None:
    paradas = data["paradas"]
    rutas = data["rutas"]
    horarios = data["horarios"]

    # Validar rutas
    for route_id, route in rutas.items():

        if route["codigo"] != route_id:
            raise ValueError(
                f"Ruta {route_id}: codigo diferente ({route['codigo']})"
            )

        route_stops = route["paradas"]

        if len(route_stops) != len(set(route_stops)):
            raise ValueError(
                f"Ruta {route_id}: contiene paradas duplicadas"
            )

        for stop_id in route_stops:
            if stop_id not in paradas:
                raise ValueError(
                    f"Ruta {route_id}: parada inexistente {stop_id}"
                )

    # Validar horarios
    for day_type, day_routes in horarios.items():

        for route_id, trips in day_routes.items():

            if route_id not in rutas:
                raise ValueError(
                    f"{day_type}: ruta inexistente {route_id}"
                )

            valid_stops = set(rutas[route_id]["paradas"])

            for trip_number, trip in enumerate(trips, start=1):

                for stop_id, time_value in trip.items():

                    if stop_id not in valid_stops:
                        raise ValueError(
                            f"{day_type} / {route_id} / viaje {trip_number}: "
                            f"parada {stop_id} no pertenece a la ruta"
                        )

                    if time_value is not None:
                        normalizar_hora(time_value)


BASE_DIR = Path(__file__).resolve().parent
DATA_FILE = BASE_DIR / "data" / "lineas.json"


print("Usando JSON en:", DATA_FILE)

if not DATA_FILE.exists():
    raise FileNotFoundError(DATA_FILE)


# =========================
# CARGAR JSON
# =========================

with open(DATA_FILE, "r", encoding="utf-8") as f:
    data = json.load(f)


# =========================
# VALIDAR ANTES DE TOCAR DB
# =========================

validar_datos(data)

print("JSON validado correctamente")
print("Paradas:", len(data["paradas"]))
print("Rutas:", len(data["rutas"]))
print("Tipos de día:", list(data["horarios"].keys()))


# =========================
# CONEXIÓN
# =========================

DATABASE_URL = os.getenv("DATABASE_URL")

if DATABASE_URL:
    print("Conectando mediante DATABASE_URL")
    conn = psycopg2.connect(DATABASE_URL)

else:
    print("Conectando a PostgreSQL local")

    conn = psycopg2.connect(
        dbname=os.getenv("DB_NAME", "hermanos_alvarez"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
    )


try:

    # La transacción completa se confirma solo si TODO funciona.
    with conn:

        with conn.cursor() as cur:

            # =========================
            # LIMPIAR DATOS ANTERIORES
            # =========================

            print("Eliminando datos anteriores...")

            cur.execute("DELETE FROM trip_stop_times")
            cur.execute("DELETE FROM trip_schedules")
            cur.execute("DELETE FROM route_stops")
            cur.execute("DELETE FROM routes")
            cur.execute("DELETE FROM stops")


            # =========================
            # PARADAS
            # =========================

            print("Insertando paradas...")

            for stop_id, stop in data["paradas"].items():

                cur.execute(
                    """
                    INSERT INTO stops (id, name, on_demand)
                    VALUES (%s, %s, %s)
                    """,
                    (
                        stop_id,
                        stop["nombre"],
                        stop["bajoDemanda"],
                    ),
                )


            # =========================
            # RUTAS
            # =========================

            print("Insertando rutas...")

            for route_id, route in data["rutas"].items():

                cur.execute(
                    """
                    INSERT INTO routes (id, code)
                    VALUES (%s, %s)
                    """,
                    (
                        route_id,
                        route["codigo"],
                    ),
                )


            # =========================
            # PARADAS DE RUTA
            # =========================

            print("Insertando recorrido de rutas...")

            for route_id, route in data["rutas"].items():

                for order, stop_id in enumerate(route["paradas"]):

                    cur.execute(
                        """
                        INSERT INTO route_stops
                            (route_id, stop_id, stop_order)
                        VALUES (%s, %s, %s)
                        """,
                        (
                            route_id,
                            stop_id,
                            order,
                        ),
                    )


            # =========================
            # HORARIOS
            # =========================

            print("Insertando horarios...")

            total_trips = 0
            total_times = 0

            for day_type, routes in data["horarios"].items():

                for route_id, trips in routes.items():

                    for trip in trips:

                        cur.execute(
                            """
                            INSERT INTO trip_schedules
                                (route_id, day_type)
                            VALUES (%s, %s)
                            RETURNING id
                            """,
                            (
                                route_id,
                                day_type,
                            ),
                        )

                        trip_id = cur.fetchone()[0]
                        total_trips += 1

                        for stop_id, time_value in trip.items():

                            time_value = normalizar_hora(time_value)

                            # null significa que esa expedición
                            # no pasa por esa parada
                            if time_value is None:
                                continue

                            cur.execute(
                                """
                                INSERT INTO trip_stop_times
                                    (trip_id, stop_id, time_value)
                                VALUES (%s, %s, %s)
                                """,
                                (
                                    trip_id,
                                    stop_id,
                                    time_value,
                                ),
                            )

                            total_times += 1


    print()
    print("================================")
    print("IMPORTACIÓN COMPLETADA")
    print("================================")
    print("Paradas:", len(data["paradas"]))
    print("Rutas:", len(data["rutas"]))
    print("Expediciones:", total_trips)
    print("Horas de paso:", total_times)
    print("Commit realizado correctamente")


finally:
    conn.close()
