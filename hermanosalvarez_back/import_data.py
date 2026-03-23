import json
import psycopg2

# 🔌 conexión DB
conn = psycopg2.connect(
    dbname="hermanos_alvarez",
    user="postgres",
    password="1234",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

# 📂 cargar JSON
with open("data/lineas.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# ---------------------------
# 🟢 INSERTAR PARADAS
# ---------------------------
for stop_id, stop in data["paradas"].items():
    cur.execute("""
        INSERT INTO stops (id, name, on_demand)
        VALUES (%s, %s, %s)
        ON CONFLICT (id) DO NOTHING
    """, (stop_id, stop["nombre"], stop["bajoDemanda"]))

# ---------------------------
# 🔵 INSERTAR RUTAS
# ---------------------------
for route_id, route in data["rutas"].items():
    cur.execute("""
        INSERT INTO routes (id, code)
        VALUES (%s, %s)
        ON CONFLICT (id) DO NOTHING
    """, (route_id, route["codigo"]))

# ---------------------------
# 🟣 INSERTAR route_stops
# ---------------------------
for route_id, route in data["rutas"].items():
    for order, stop_id in enumerate(route["paradas"]):
        cur.execute("""
            INSERT INTO route_stops (route_id, stop_id, stop_order)
            VALUES (%s, %s, %s)
            ON CONFLICT DO NOTHING
        """, (route_id, stop_id, order))

# ---------------------------
# 🔴 INSERTAR HORARIOS
# ---------------------------
for day_type, routes in data["horarios"].items():
    for route_id, trips in routes.items():

        for trip in trips:
            # crear viaje
            cur.execute("""
                INSERT INTO trip_schedules (route_id, day_type)
                VALUES (%s, %s)
                RETURNING id
            """, (route_id, day_type))

            trip_id = cur.fetchone()[0]

            # insertar tiempos por parada
            for stop_id, time in trip.items():
                if time is None:
                    continue

                cur.execute("""
                    INSERT INTO trip_stop_times (trip_id, stop_id, time_value)
                    VALUES (%s, %s, %s)
                """, (trip_id, stop_id, time))

# guardar cambios
conn.commit()

cur.close()
conn.close()

print("✅ Datos importados correctamente")