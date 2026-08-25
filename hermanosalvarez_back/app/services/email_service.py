import html
import os

import resend

from app.schemas.solicitud_discrecional import SolicitudDiscrecional


class EmailServiceError(Exception):
    """Error controlado del servicio de correo."""

def _texto_seguro(valor) -> str:
    if valor is None or valor == "":
        return "No indicado"

    return html.escape(str(valor))


def construir_email_solicitud(
    solicitud: SolicitudDiscrecional,
) -> dict:
    email_from = os.getenv(
        "EMAIL_FROM",
        "Autocares Hermanos Álvarez <onboarding@resend.dev>",
    )
    email_destino = os.getenv("EMAIL_DESTINO")

    vuelta = (
        "Sí"
        if solicitud.tipo_viaje.value == "ida_vuelta"
        else "No"
    )

    html_email = f"""
    <h2>Nueva solicitud de servicio discrecional</h2>

    <h3>Datos de contacto</h3>
    <p><strong>Nombre:</strong> {_texto_seguro(solicitud.nombre)}</p>
    <p><strong>Empresa:</strong> {_texto_seguro(solicitud.empresa)}</p>
    <p><strong>Teléfono:</strong> {_texto_seguro(solicitud.telefono)}</p>
    <p><strong>Email:</strong> {_texto_seguro(solicitud.email)}</p>

    <h3>Datos del viaje</h3>
    <p><strong>Origen:</strong> {_texto_seguro(solicitud.origen)}</p>
    <p><strong>Destino:</strong> {_texto_seguro(solicitud.destino)}</p>
    <p><strong>Fecha de ida:</strong> {_texto_seguro(solicitud.fecha_ida)}</p>
    <p><strong>Hora de ida:</strong> {_texto_seguro(solicitud.hora_ida)}</p>
    <p><strong>Ida y vuelta:</strong> {vuelta}</p>
    <p><strong>Fecha de vuelta:</strong> {_texto_seguro(solicitud.fecha_vuelta)}</p>
    <p><strong>Hora de vuelta:</strong> {_texto_seguro(solicitud.hora_vuelta)}</p>
    <p><strong>Número de viajeros:</strong> {solicitud.viajeros}</p>

    <h3>Observaciones</h3>
    <p>{_texto_seguro(solicitud.observaciones)}</p>
    """

    return {
        "from": email_from,
        "to": [email_destino] if email_destino else [],
        "reply_to": str(solicitud.email),
        "subject": "Nueva solicitud de servicio discrecional",
        "html": html_email,
    }


async def enviar_solicitud_discrecional(
    solicitud: SolicitudDiscrecional,
):
    api_key = os.getenv("RESEND_API_KEY")
    email_destino = os.getenv("EMAIL_DESTINO")

    if not api_key:
        raise EmailServiceError(
            "RESEND_API_KEY no configurada."
        )

    if not email_destino:
        raise EmailServiceError(
            "EMAIL_DESTINO no configurado."
        )

    resend.api_key = api_key

    params = construir_email_solicitud(solicitud)

    try:
        return await resend.Emails.send_async(params)

    except Exception as exc:
        raise EmailServiceError(
            "No se pudo enviar el correo."
        ) from exc
