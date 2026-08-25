import logging
import os
from enum import Enum


from app.schemas.solicitud_discrecional import SolicitudDiscrecional
from fastapi import Depends, FastAPI, Query, Request
from fastapi.exceptions import RequestValidationError
from fastapi.exception_handlers import request_validation_exception_handler
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import and_
from sqlalchemy.orm import Session, aliased

from app.db import get_db
from app.models import Stop, RouteStop, TripSchedule, TripStopTime
from app.services.email_service import (
    EmailServiceError,
    enviar_solicitud_discrecional,
)

# ============================================================
# CONFIGURACIÓN
# ============================================================

class DiaServicio(str, Enum):
    laborable = "laborable"
    sabado = "sabado"
    domingo_festivos = "domingo_festivos"


VERCEL_ENV = os.getenv(
    "VERCEL_ENV",
    "development",
).lower()

IS_PRODUCTION = VERCEL_ENV == "production"

logger = logging.getLogger("uvicorn.error")


# ============================================================
# APLICACIÓN FASTAPI
# ============================================================

app = FastAPI(
    title="Autocares Hermanos Álvarez API",

    # Swagger disponible durante desarrollo.
    # En producción no exponemos documentación ni OpenAPI.
    docs_url=None if IS_PRODUCTION else "/docs",
    redoc_url=None if IS_PRODUCTION else "/redoc",
    openapi_url=None if IS_PRODUCTION else "/openapi.json",
)


# ============================================================
# CORS
# ============================================================

if IS_PRODUCTION:
    ALLOWED_ORIGINS = [
        "https://hermanos-alvarez-web.vercel.app",
    ]
elif VERCEL_ENV == "preview":
    ALLOWED_ORIGINS = [
        "https://hermanos-alvarez-web-git-development-sirzazos-projects.vercel.app",
    ]
else:
    ALLOWED_ORIGINS = [
        "http://localhost:8080",
        "http://127.0.0.1:8080",
    ]


app.add_middleware(
    CORSMiddleware,

    # Solo nuestras aplicaciones pueden realizar
    # peticiones desde un navegador.
    allow_origins=ALLOWED_ORIGINS,

    # Actualmente no utilizamos cookies de autenticación
    # ni credenciales cross-origin.
    allow_credentials=False,

    # Métodos utilizados actualmente por la API.
    allow_methods=["GET", "POST"],

    # Cabeceras aceptadas.
    allow_headers=["Content-Type"],
)


# ============================================================
# CABECERAS DE SEGURIDAD
# ============================================================

@app.middleware("http")
async def add_security_headers(
    request: Request,
    call_next,
):
    response = await call_next(request)

    # Evita que el navegador intente adivinar
    # tipos MIME diferentes a los declarados.
    response.headers["X-Content-Type-Options"] = "nosniff"

    # Impide que la API pueda mostrarse dentro de iframes.
    response.headers["X-Frame-Options"] = "DENY"

    # Evita enviar información del origen al navegar.
    response.headers["Referrer-Policy"] = "no-referrer"

    # La API no necesita acceso a estas capacidades
    # del navegador.
    response.headers["Permissions-Policy"] = (
        "camera=(), "
        "microphone=(), "
        "geolocation=()"
    )

    # Esta CSP es adecuada para una API JSON,
    # pero NO la aplicamos en desarrollo porque
    # rompería Swagger /docs.
    if IS_PRODUCTION:
        response.headers["Content-Security-Policy"] = (
            "default-src 'none'; "
            "frame-ancestors 'none'; "
            "base-uri 'none'; "
            "form-action 'none'"
        )

    return response


# ============================================================
# VALIDACIÓN DE PETICIONES
# ============================================================

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request,
    exc: RequestValidationError,
):
    """
    En desarrollo mantenemos los errores detallados de FastAPI
    para poder depurar.

    En producción evitamos devolver al cliente todos los datos
    introducidos en una petición inválida.
    """

    if not IS_PRODUCTION:
        return await request_validation_exception_handler(
            request,
            exc,
        )

    return JSONResponse(
        status_code=422,
        content={
            "detail": "Parámetros de solicitud no válidos.",
        },
    )


# ============================================================
# MANEJO GLOBAL DE ERRORES
# ============================================================

@app.exception_handler(Exception)
async def global_exception_handler(
    request: Request,
    exc: Exception,
):
    """
    Registra internamente el error pero nunca devuelve
    detalles técnicos al cliente.
    """

    logger.error(
        "Error interno en %s %s",
        request.method,
        request.url.path,
        exc_info=(
            type(exc),
            exc,
            exc.__traceback__,
        ),
    )

    return JSONResponse(
        status_code=500,
        content={
            "detail": "Error interno del servidor.",
        },
    )


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():
    return {
        "mensaje": "API funcionando 🚀",
    }


# ============================================================
# PARADAS
# ============================================================

@app.get("/paradas")
def get_paradas(
    dia: DiaServicio | None = Query(
        default=None,
    ),
    db: Session = Depends(get_db),
):
    """
    Devuelve las paradas disponibles.

    Si se indica un día, devuelve únicamente las paradas
    desde las que se puede iniciar realmente algún viaje.
    """

    # --------------------------------------------------------
    # Sin día: devolver todas las paradas
    # --------------------------------------------------------

    if dia is None:
        stops = db.query(Stop).all()

    # --------------------------------------------------------
    # Con día: solo orígenes disponibles
    # --------------------------------------------------------

    else:
        OrigenRouteStop = aliased(RouteStop)
        DestinoRouteStop = aliased(RouteStop)

        HoraOrigen = aliased(TripStopTime)
        HoraDestino = aliased(TripStopTime)

        stops = (
            db.query(Stop)

            .join(
                OrigenRouteStop,
                OrigenRouteStop.stop_id == Stop.id,
            )

            .join(
                DestinoRouteStop,
                and_(
                    DestinoRouteStop.route_id
                    == OrigenRouteStop.route_id,

                    DestinoRouteStop.stop_order
                    > OrigenRouteStop.stop_order,
                ),
            )

            .join(
                TripSchedule,
                and_(
                    TripSchedule.route_id
                    == OrigenRouteStop.route_id,

                    TripSchedule.day_type
                    == dia.value,
                ),
            )

            .join(
                HoraOrigen,
                and_(
                    HoraOrigen.trip_id
                    == TripSchedule.id,

                    HoraOrigen.stop_id
                    == OrigenRouteStop.stop_id,
                ),
            )

            .join(
                HoraDestino,
                and_(
                    HoraDestino.trip_id
                    == TripSchedule.id,

                    HoraDestino.stop_id
                    == DestinoRouteStop.stop_id,
                ),
            )

            .filter(
                HoraDestino.time_value
                > HoraOrigen.time_value,
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

    resultado.sort(
        key=lambda x: x["nombre"],
    )

    return resultado


# ============================================================
# DESTINOS VÁLIDOS
# ============================================================

@app.get("/destinos-validos")
def get_destinos_validos(
    origen: str = Query(
        ...,
        min_length=1,
        max_length=64,
    ),

    dia: DiaServicio = Query(
        default=DiaServicio.laborable,
    ),

    db: Session = Depends(get_db),
):
    """
    Devuelve los destinos realmente alcanzables desde
    un origen para el tipo de día seleccionado.
    """

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
                OrigenRouteStop.route_id
                == DestinoRouteStop.route_id,

                OrigenRouteStop.stop_id
                == origen,

                OrigenRouteStop.stop_order
                < DestinoRouteStop.stop_order,
            ),
        )

        .join(
            TripSchedule,
            and_(
                TripSchedule.route_id
                == OrigenRouteStop.route_id,

                TripSchedule.day_type
                == dia.value,
            ),
        )

        .join(
            HoraOrigen,
            and_(
                HoraOrigen.trip_id
                == TripSchedule.id,

                HoraOrigen.stop_id
                == origen,
            ),
        )

        .join(
            HoraDestino,
            and_(
                HoraDestino.trip_id
                == TripSchedule.id,

                HoraDestino.stop_id
                == DestinoRouteStop.stop_id,
            ),
        )

        .filter(
            HoraDestino.time_value
            > HoraOrigen.time_value,
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

    resultado.sort(
        key=lambda x: x["nombre"],
    )

    return resultado


# ============================================================
# HORARIOS
# ============================================================

@app.get("/horarios")
def get_horarios(
    origen: str = Query(
        ...,
        min_length=1,
        max_length=64,
    ),

    destino: str = Query(
        ...,
        min_length=1,
        max_length=64,
    ),

    dia: DiaServicio = Query(...),

    db: Session = Depends(get_db),
):
    """
    Devuelve todos los horarios disponibles entre
    un origen y un destino para el día seleccionado.
    """

    OrigenRouteStop = aliased(RouteStop)
    DestinoRouteStop = aliased(RouteStop)

    HoraOrigen = aliased(TripStopTime)
    HoraDestino = aliased(TripStopTime)

    viajes = (
        db.query(
            TripSchedule.route_id,

            HoraOrigen.time_value.label(
                "salida",
            ),

            HoraDestino.time_value.label(
                "llegada",
            ),
        )

        .join(
            OrigenRouteStop,
            and_(
                OrigenRouteStop.route_id
                == TripSchedule.route_id,

                OrigenRouteStop.stop_id
                == origen,
            ),
        )

        .join(
            DestinoRouteStop,
            and_(
                DestinoRouteStop.route_id
                == TripSchedule.route_id,

                DestinoRouteStop.stop_id
                == destino,

                DestinoRouteStop.stop_order
                > OrigenRouteStop.stop_order,
            ),
        )

        .join(
            HoraOrigen,
            and_(
                HoraOrigen.trip_id
                == TripSchedule.id,

                HoraOrigen.stop_id
                == origen,
            ),
        )

        .join(
            HoraDestino,
            and_(
                HoraDestino.trip_id
                == TripSchedule.id,

                HoraDestino.stop_id
                == destino,
            ),
        )

        .filter(
            TripSchedule.day_type
            == dia.value,

            HoraDestino.time_value
            > HoraOrigen.time_value,
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

    resultados.sort(
        key=lambda x: x["salida"],
    )

    rutas = sorted(
        {
            resultado["ruta"]
            for resultado in resultados
        }
    )

    return {
        # Compatibilidad con versiones anteriores
        "ruta": (
            rutas[0]
            if len(rutas) == 1
            else None
        ),

        # Todas las rutas compatibles
        "rutas": rutas,

        # Horarios disponibles
        "horarios": resultados,
    }

@app.post("/solicitudes-discrecionales")
async def crear_solicitud_discrecional(
    solicitud: SolicitudDiscrecional,
):
    try:
        await enviar_solicitud_discrecional(solicitud)

    except EmailServiceError:
        logger.exception(
            "Error enviando solicitud discrecional."
        )

        return JSONResponse(
            status_code=503,
            content={
                "detail": (
                    "No se ha podido enviar la solicitud. "
                    "Inténtelo de nuevo más tarde."
                )
            },
        )

    return {
        "mensaje": "Solicitud enviada correctamente.",
        "estado": "enviada",
    }
