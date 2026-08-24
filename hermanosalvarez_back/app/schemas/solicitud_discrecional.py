from datetime import date, time
from enum import Enum

from pydantic import (
    BaseModel,
    EmailStr,
    Field,
    field_validator,
    model_validator,
)


class TipoViaje(str, Enum):
    IDA = "ida"
    IDA_VUELTA = "ida_vuelta"


class SolicitudDiscrecional(BaseModel):
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

    # Campo invisible para humanos.
    # Si un bot lo rellena, rechazamos la solicitud.
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
        if not self.acepta_privacidad:
            raise ValueError(
                "Debe aceptarse la política de privacidad."
            )

        if self.website:
            raise ValueError("Solicitud no válida.")

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

        return self
