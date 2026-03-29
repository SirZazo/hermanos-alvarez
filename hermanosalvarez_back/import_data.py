import json
from pathlib import Path
import psycopg2


def normalizar_hora(hora: str | None) -> str | None:
    if hora is None:
        return None
    hora = hora.strip()
    h, m = hora.split(":")
    return f"{int(h):02d}:{int(m):02d}"


BASE_DIR = Path(__file__).resolve().parent
DATA_FILE = BASE_DIR / "data" / "lineas.json"

print("Usando JSON en:", DATA_FILE)
print("¿Existe?", DATA_FILE.exists())

conn = psycopg2.connect(
    dbname="hermanos_alvarez",
    user="postgres",
    password="1234",
    host="localhost",
    port="5432",
)

cur = conn.cursor()

with open(DATA_FILE, "r", encoding="utf-8") as f:
    data = json.load(f)

print("Paradas:", len(data["paradas"]))
print("Rutas:", len(data["rutas"]))
print("Tipos de día:", list(data["horarios"].keys()))

# PARADAS
for stop_id, stop in data["paradas"].items():
    cur.execute(
        """
        INSERT INTO stops (id, name, on_demand)
        VALUES (%s, %s, %s)
        ON CONFLICT (id) DO UPDATE
        SET name = EXCLUDED.name,
            on_demand = EXCLUDED.on_demand
        """,
        (stop_id, stop["nombre"], stop["bajoDemanda"]),
    )

# RUTAS
for route_id, route in data["rutas"].items():
    cur.execute(
        """
        INSERT INTO routes (id, code)
        VALUES (%s, %s)
        ON CONFLICT (id) DO UPDATE
        SET code = EXCLUDED.code
        """,
        (route_id, route["codigo"]),
    )

# ROUTE_STOPS
for route_id, route in data["rutas"].items():
    for order, stop_id in enumerate(route["paradas"]):
        cur.execute(
            """
            INSERT INTO route_stops (route_id, stop_id, stop_order)
            VALUES (%s, %s, %s)
            ON CONFLICT (route_id, stop_id) DO UPDATE
            SET stop_order = EXCLUDED.stop_order
            """,
            (route_id, stop_id, order),
        )

# HORARIOS
for day_type, routes in data["horarios"].items():
    for route_id, trips in routes.items():
        for trip in trips:
            cur.execute(
                """
                INSERT INTO trip_schedules (route_id, day_type)
                VALUES (%s, %s)
                RETURNING id
                """,
                (route_id, day_type),
            )
            trip_id = cur.fetchone()[0]

            for stop_id, time_value in trip.items():
                time_value = normalizar_hora(time_value)
                if time_value is None:
                    continue

                cur.execute(
                    """
                    INSERT INTO trip_stop_times (trip_id, stop_id, time_value)
                    VALUES (%s, %s, %s)
                    """,
                    (trip_id, stop_id, time_value),
                )

conn.commit()
print("Commit hecho correctamente")

cur.close()
conn.close()

print("✅ Datos importados correctamente")