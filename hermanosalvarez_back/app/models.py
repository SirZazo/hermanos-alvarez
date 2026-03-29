from sqlalchemy import Column, Integer, String, ForeignKey
from app.db import Base


class Stop(Base):
    __tablename__ = "stops"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    on_demand = Column(String, nullable=True)


class Route(Base):
    __tablename__ = "routes"

    id = Column(String, primary_key=True)
    code = Column(String, nullable=False)


class RouteStop(Base):
    __tablename__ = "route_stops"

    route_id = Column(String, ForeignKey("routes.id"), primary_key=True)
    stop_id = Column(String, ForeignKey("stops.id"), primary_key=True)
    stop_order = Column(Integer, nullable=False)


class TripSchedule(Base):
    __tablename__ = "trip_schedules"

    id = Column(Integer, primary_key=True, autoincrement=True)
    route_id = Column(String, ForeignKey("routes.id"), nullable=False)
    day_type = Column(String, nullable=False)


class TripStopTime(Base):
    __tablename__ = "trip_stop_times"

    id = Column(Integer, primary_key=True, autoincrement=True)
    trip_id = Column(Integer, ForeignKey("trip_schedules.id"), nullable=False)
    stop_id = Column(String, ForeignKey("stops.id"), nullable=False)
    time_value = Column(String, nullable=False)
