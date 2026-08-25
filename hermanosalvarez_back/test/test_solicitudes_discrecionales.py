from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

from fastapi.testclient import TestClient

from app.main import app
from app.schemas.solicitud_discrecional import SolicitudDiscrecional
from app.services.email_service import (
    EmailServiceError,
    construir_email_solicitud,
)


client = TestClient(app)


def solicitud_valida():
    fecha = (
        datetime.now(ZoneInfo("Europe/Madrid")).date()
        + timedelta(days=30)
    )

    return {
        "nombre": "Juan Pérez",
        "empresa": "Empresa de ejemplo S.L.",
        "telefono": "+34 600 123 456",
        "email": "juan@example.com",
        "origen": "Torrijos",
        "destino": "Madrid",
        "fecha_ida": fecha.isoformat(),
        "hora_ida": "08:00",
        "tipo_viaje": "ida_vuelta",
        "fecha_vuelta": fecha.isoformat(),
        "hora_vuelta": "20:00",
        "viajeros": 45,
        "observaciones": "Viaje de grupo.",
        "acepta_privacidad": True,
        "website": "",
    }


def test_solicitud_valida(monkeypatch):
    async def envio_falso(solicitud):
        return {"id": "email-test"}

    monkeypatch.setattr(
        "app.main.enviar_solicitud_discrecional",
        envio_falso,
    )

    response = client.post(
        "/solicitudes-discrecionales",
        json=solicitud_valida(),
    )

    assert response.status_code == 200
    assert response.json() == {
        "mensaje": "Solicitud enviada correctamente.",
        "estado": "enviada",
    }


def test_privacidad_es_obligatoria():
    datos = solicitud_valida()
    datos["acepta_privacidad"] = False

    response = client.post(
        "/solicitudes-discrecionales",
        json=datos,
    )

    assert response.status_code == 422


def test_honeypot_rechaza_bot():
    datos = solicitud_valida()
    datos["website"] = "https://spam.example"

    response = client.post(
        "/solicitudes-discrecionales",
        json=datos,
    )

    assert response.status_code == 422


def test_fecha_vuelta_no_puede_ser_anterior():
    datos = solicitud_valida()

    fecha_ida = datetime.fromisoformat(
        datos["fecha_ida"]
    ).date()

    datos["fecha_vuelta"] = (
        fecha_ida - timedelta(days=1)
    ).isoformat()

    response = client.post(
        "/solicitudes-discrecionales",
        json=datos,
    )

    assert response.status_code == 422


def test_email_invalido():
    datos = solicitud_valida()
    datos["email"] = "esto-no-es-un-email"

    response = client.post(
        "/solicitudes-discrecionales",
        json=datos,
    )

    assert response.status_code == 422


def test_numero_viajeros_fuera_de_limite():
    datos = solicitud_valida()
    datos["viajeros"] = 500

    response = client.post(
        "/solicitudes-discrecionales",
        json=datos,
    )

    assert response.status_code == 422


def test_error_servicio_email(monkeypatch):
    async def envio_fallido(solicitud):
        raise EmailServiceError(
            "Error simulado de Resend."
        )

    monkeypatch.setattr(
        "app.main.enviar_solicitud_discrecional",
        envio_fallido,
    )

    response = client.post(
        "/solicitudes-discrecionales",
        json=solicitud_valida(),
    )

    assert response.status_code == 503
    assert response.json() == {
        "detail": (
            "No se ha podido enviar la solicitud. "
            "Inténtelo de nuevo más tarde."
        )
    }


def test_fecha_ida_no_puede_estar_en_pasado():
    datos = solicitud_valida()

    ayer = (
        datetime.now(ZoneInfo("Europe/Madrid")).date()
        - timedelta(days=1)
    )

    datos["fecha_ida"] = ayer.isoformat()
    datos["fecha_vuelta"] = ayer.isoformat()

    response = client.post(
        "/solicitudes-discrecionales",
        json=datos,
    )

    assert response.status_code == 422


def test_campos_desconocidos_son_rechazados():
    datos = solicitud_valida()
    datos["campo_inventado"] = "valor"

    response = client.post(
        "/solicitudes-discrecionales",
        json=datos,
    )

    assert response.status_code == 422


def test_solo_ida_no_admite_datos_de_vuelta():
    datos = solicitud_valida()
    datos["tipo_viaje"] = "ida"

    response = client.post(
        "/solicitudes-discrecionales",
        json=datos,
    )

    assert response.status_code == 422


def test_hora_vuelta_no_puede_ser_anterior_mismo_dia():
    datos = solicitud_valida()
    datos["hora_ida"] = "18:00"
    datos["hora_vuelta"] = "10:00"

    response = client.post(
        "/solicitudes-discrecionales",
        json=datos,
    )

    assert response.status_code == 422


def test_asunto_email_no_contiene_datos_del_usuario():
    datos = solicitud_valida()
    solicitud = SolicitudDiscrecional.model_validate(datos)

    email = construir_email_solicitud(solicitud)

    assert email["subject"] == (
        "Nueva solicitud de servicio discrecional"
    )
    assert datos["origen"] not in email["subject"]
    assert datos["destino"] not in email["subject"]
