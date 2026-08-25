from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

import httpx
from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


PREVIEW_HOSTNAME = (
    "hermanos-alvarez-web-git-development-"
    "sirzazos-projects.vercel.app"
)

TURNSTILE_ACTION = "solicitud_discrecional"


def solicitud_valida(
    incluir_token: bool = True,
):
    fecha = (
        datetime.now(
            ZoneInfo("Europe/Madrid")
        ).date()
        + timedelta(days=30)
    )

    datos = {
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

    if incluir_token:
        datos["turnstile_token"] = "token-prueba"

    return datos


class FakeResponse:
    def __init__(self, payload):
        self.payload = payload

    def raise_for_status(self):
        return None

    def json(self):
        return self.payload


def configurar_turnstile(
    monkeypatch,
):
    monkeypatch.setenv(
        "TURNSTILE_ENABLED",
        "true",
    )
    monkeypatch.setenv(
        "TURNSTILE_SECRET_KEY",
        "secret-test",
    )
    monkeypatch.delenv(
        "TURNSTILE_EXPECTED_HOSTNAME",
        raising=False,
    )
    monkeypatch.delenv(
        "TURNSTILE_EXPECTED_ACTION",
        raising=False,
    )


def simular_cloudflare(
    monkeypatch,
    payload=None,
    error=None,
):
    class FakeAsyncClient:
        def __init__(
            self,
            *args,
            **kwargs,
        ):
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(
            self,
            exc_type,
            exc,
            traceback,
        ):
            return False

        async def post(
            self,
            *args,
            **kwargs,
        ):
            if error is not None:
                raise error

            return FakeResponse(payload)

    monkeypatch.setattr(
        (
            "app.services.turnstile_service."
            "httpx.AsyncClient"
        ),
        FakeAsyncClient,
    )


def simular_email(monkeypatch):
    async def envio_falso(solicitud):
        return {"id": "email-test"}

    monkeypatch.setattr(
        "app.main.enviar_solicitud_discrecional",
        envio_falso,
    )


def test_turnstile_desactivado_no_exige_token(
    monkeypatch,
):
    monkeypatch.setenv(
        "TURNSTILE_ENABLED",
        "false",
    )

    simular_email(monkeypatch)

    response = client.post(
        "/solicitudes-discrecionales",
        json=solicitud_valida(
            incluir_token=False,
        ),
    )

    assert response.status_code == 200


def test_turnstile_activado_exige_token(
    monkeypatch,
):
    configurar_turnstile(monkeypatch)

    response = client.post(
        "/solicitudes-discrecionales",
        json=solicitud_valida(
            incluir_token=False,
        ),
    )

    assert response.status_code == 403
    assert response.json() == {
        "detail": (
            "No se ha podido verificar la solicitud. "
            "Vuelva a intentarlo."
        )
    }


def test_turnstile_rechaza_token_invalido(
    monkeypatch,
):
    configurar_turnstile(monkeypatch)

    simular_cloudflare(
        monkeypatch,
        payload={
            "success": False,
            "error-codes": [
                "invalid-input-response",
            ],
        },
    )

    response = client.post(
        "/solicitudes-discrecionales",
        json=solicitud_valida(),
    )

    assert response.status_code == 403


def test_error_cloudflare_devuelve_503(
    monkeypatch,
):
    configurar_turnstile(monkeypatch)

    simular_cloudflare(
        monkeypatch,
        error=httpx.ConnectError(
            "Cloudflare no disponible."
        ),
    )

    response = client.post(
        "/solicitudes-discrecionales",
        json=solicitud_valida(),
    )

    assert response.status_code == 503
    assert response.json() == {
        "detail": (
            "No se ha podido verificar la solicitud. "
            "Inténtelo de nuevo más tarde."
        )
    }


def test_turnstile_token_valido_permite_envio(
    monkeypatch,
):
    configurar_turnstile(monkeypatch)

    monkeypatch.setenv(
        "TURNSTILE_EXPECTED_HOSTNAME",
        PREVIEW_HOSTNAME,
    )
    monkeypatch.setenv(
        "TURNSTILE_EXPECTED_ACTION",
        TURNSTILE_ACTION,
    )

    simular_cloudflare(
        monkeypatch,
        payload={
            "success": True,
            "hostname": PREVIEW_HOSTNAME,
            "action": TURNSTILE_ACTION,
        },
    )

    simular_email(monkeypatch)

    response = client.post(
        "/solicitudes-discrecionales",
        json=solicitud_valida(),
    )

    assert response.status_code == 200
    assert response.json() == {
        "mensaje": (
            "Solicitud enviada correctamente."
        ),
        "estado": "enviada",
    }


def test_turnstile_rechaza_hostname_incorrecto(
    monkeypatch,
):
    configurar_turnstile(monkeypatch)

    monkeypatch.setenv(
        "TURNSTILE_EXPECTED_HOSTNAME",
        PREVIEW_HOSTNAME,
    )

    simular_cloudflare(
        monkeypatch,
        payload={
            "success": True,
            "hostname": "sitio-malicioso.example",
            "action": TURNSTILE_ACTION,
        },
    )

    response = client.post(
        "/solicitudes-discrecionales",
        json=solicitud_valida(),
    )

    assert response.status_code == 403


def test_turnstile_rechaza_action_incorrecta(
    monkeypatch,
):
    configurar_turnstile(monkeypatch)

    monkeypatch.setenv(
        "TURNSTILE_EXPECTED_HOSTNAME",
        PREVIEW_HOSTNAME,
    )
    monkeypatch.setenv(
        "TURNSTILE_EXPECTED_ACTION",
        TURNSTILE_ACTION,
    )

    simular_cloudflare(
        monkeypatch,
        payload={
            "success": True,
            "hostname": PREVIEW_HOSTNAME,
            "action": "otra_accion",
        },
    )

    response = client.post(
        "/solicitudes-discrecionales",
        json=solicitud_valida(),
    )

    assert response.status_code == 403
