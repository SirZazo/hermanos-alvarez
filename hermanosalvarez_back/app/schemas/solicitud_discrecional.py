from datetime import date, datetime, time
from enum import Enum
from zoneinfo import ZoneInfo

from pydantic import (
    BaseModel,
    ConfigDict,
    EmailStr,
    Field,
    field_validator,
    model_validator,
)


class TipoViaje(str, Enum):
    IDA = "ida"
    IDA_VUELTA = "ida_vuelta"


class SolicitudDiscrecional(BaseModel):
    model_config = ConfigDict(extra="forbid")

    nombre: str = Field(min_length=2, max_length=80)
    empresa: str | None = Field(default=None, max_length=120)

    telefono: str = Field(min_length=7, max_length=25)
    email: EmailStr

    origen: str = Field(min_length=2, max_length=120)
    destino: str = Field(min_length=2, max_length=120)

    fecha_ida: date
    hora_ida: time | None = None

    tipo_viaje: TipoViaje = TipoViaje.IDA

    fecha_vuelta: date | None = None
    hora_vuelta: time | None = None

    viajeros: int = Field(ge=1, le=200)

    observaciones: str | None = Field(
        default=None,
        max_length=1500,
    )

    acepta_privacidad: bool

    # Token generado por Cloudflare Turnstile.
    # Es opcional mientras la protección está desactivada.
    turnstile_token: str | None = Field(
        default=None,
        min_length=1,
        max_length=2048,
    )

    # Honeypot invisible para usuarios humanos.
    website: str | None = Field(
        default=None,
        max_length=200,
    )

    @field_validator(
        "nombre",
        "empresa",
        "telefono",
        "origen",
        "destino",
        "observaciones",
        "turnstile_token",
        "website",
        mode="before",
    )
    @classmethod
    def limpiar_texto(cls, value):
        if isinstance(value, str):
            value = value.strip()

            if value == "":
                return None

        return value

    @field_validator("telefono")
    @classmethod
    def validar_telefono(cls, value: str) -> str:
        caracteres_permitidos = set(
            "0123456789+-.() "
        )

        if any(
            caracter not in caracteres_permitidos
            for caracter in value
        ):
            raise ValueError("Teléfono no válido.")

        cantidad_digitos = sum(
            caracter.isdigit()
            for caracter in value
        )

        if cantidad_digitos < 7:
            raise ValueError("Teléfono no válido.")

        return value

    @model_validator(mode="after")
    def validar_solicitud(self):
        hoy = datetime.now(
            ZoneInfo("Europe/Madrid")
        ).date()

        if not self.acepta_privacidad:
            raise ValueError(
                "Debe aceptarse la política de privacidad."
            )

        if self.website:
            raise ValueError("Solicitud no válida.")

        if self.fecha_ida < hoy:
            raise ValueError(
                "La fecha de ida no puede estar en el pasado."
            )

        if self.tipo_viaje == TipoViaje.IDA:
            if (
                self.fecha_vuelta is not None
                or self.hora_vuelta is not None
            ):
                raise ValueError(
                    "Un viaje solo de ida no puede incluir "
                    "datos de vuelta."
                )

        if self.tipo_viaje == TipoViaje.IDA_VUELTA:
            if self.fecha_vuelta is None:
                raise ValueError(
                    "La fecha de vuelta es obligatoria."
                )

            if self.fecha_vuelta < self.fecha_ida:
                raise ValueError(
                    "La fecha de vuelta no puede ser "
                    "anterior a la fecha de ida."
                )

            if (
                self.fecha_vuelta == self.fecha_ida
                and self.hora_ida is not None
                and self.hora_vuelta is not None
                and self.hora_vuelta < self.hora_ida
            ):
                raise ValueError(
                    "Si la ida y la vuelta son el mismo día, "
                    "la hora de vuelta no puede ser anterior "
                    "a la hora de ida."
                )

        return self
