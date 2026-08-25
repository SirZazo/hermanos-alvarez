import logging
import os

import httpx


TURNSTILE_SITEVERIFY_URL = (
    "https://challenges.cloudflare.com/turnstile/v0/siteverify"
)

logger = logging.getLogger("uvicorn.error")


class TurnstileVerificationError(Exception):
    """El token de Turnstile no es válido."""


class TurnstileServiceError(Exception):
    """No ha sido posible verificar Turnstile."""


def turnstile_esta_activado() -> bool:
    return os.getenv(
        "TURNSTILE_ENABLED",
        "false",
    ).strip().lower() in {
        "1",
        "true",
        "yes",
        "on",
    }


async def verificar_turnstile(
    token: str | None,
) -> None:
    if not turnstile_esta_activado():
        return

    secret_key = os.getenv(
        "TURNSTILE_SECRET_KEY",
        "",
    ).strip()

    if not secret_key:
        logger.error(
            "Turnstile está activado pero falta "
            "TURNSTILE_SECRET_KEY."
        )
        raise TurnstileServiceError()

    if not token:
        raise TurnstileVerificationError()

    try:
        async with httpx.AsyncClient(
            timeout=5.0,
        ) as client:
            response = await client.post(
                TURNSTILE_SITEVERIFY_URL,
                data={
                    "secret": secret_key,
                    "response": token,
                },
            )

            response.raise_for_status()

    except httpx.HTTPError as exc:
        logger.exception(
            "Error comunicando con Cloudflare Turnstile."
        )
        raise TurnstileServiceError() from exc

    try:
        resultado = response.json()

    except ValueError as exc:
        logger.exception(
            "Respuesta no válida de Cloudflare Turnstile."
        )
        raise TurnstileServiceError() from exc

    if resultado.get("success") is not True:
        logger.warning(
            "Turnstile rechazó una solicitud. Errores: %s",
            resultado.get("error-codes", []),
        )
        raise TurnstileVerificationError()

    hostname_esperado = os.getenv(
        "TURNSTILE_EXPECTED_HOSTNAME",
        "",
    ).strip()

    if (
        hostname_esperado
        and resultado.get("hostname") != hostname_esperado
    ):
        logger.warning(
            "Turnstile devolvió un hostname inesperado."
        )
        raise TurnstileVerificationError()

    action_esperada = os.getenv(
        "TURNSTILE_EXPECTED_ACTION",
        "",
    ).strip()

    if (
        action_esperada
        and resultado.get("action") != action_esperada
    ):
        logger.warning(
            "Turnstile devolvió una action inesperada."
        )
        raise TurnstileVerificationError()
