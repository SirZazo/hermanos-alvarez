from fastapi.testclient import TestClient
from app.services.email_service import EmailServiceError
from app.main import app


client = TestClient(app)


def solicitud_valida():
    return {
        "nombre": "Juan Pérez",
        "empresa": "Empresa de ejemplo S.L.",
        "telefono": "+34 600 123 456",
        "email": "juan@example.com",
        "origen": "Torrijos",
        "destino": "Madrid",
        "fecha_ida": "2026-09-15",
        "hora_ida": "08:00",
        "tipo_viaje": "ida_vuelta",
        "fecha_vuelta": "2026-09-15",
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
    datos["fecha_vuelta"] = "2026-09-14"

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