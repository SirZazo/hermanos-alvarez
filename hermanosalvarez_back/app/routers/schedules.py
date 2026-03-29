from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.db import get_db
from app.models import TripSchedule, TripStopTime

router = APIRouter()

@router.get("/")
def get_schedules(
    route_id: int | None = None,
    day_type: str | None = None,
    db: Session = Depends(get_db)
):
    query = db.query(TripSchedule)

    if route_id:
        query = query.filter(TripSchedule.route_id == route_id)

    if day_type:
        query = query.filter(TripSchedule.day_type == day_type)

    trips = query.all()

    result = []

    for trip in trips:
        stop_times = (
            db.query(TripStopTime)
            .filter(TripStopTime.trip_id == trip.id)
            .order_by(TripStopTime.stop_id)
            .all()
        )

        result.append({
            "trip_id": trip.id,
            "route_id": trip.route_id,
            "day_type": trip.day_type,
            "stops": [
                {
                    "stop_id": st.stop_id,
                    "time": st.time_value
                }
                for st in stop_times
            ]
        })

    return result