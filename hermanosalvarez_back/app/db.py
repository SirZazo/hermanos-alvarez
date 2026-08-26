import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker


load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise RuntimeError(
        "DATABASE_URL no está configurada."
    )


engine = create_engine(
    DATABASE_URL,

    # Comprueba que una conexión siga viva antes de reutilizarla.
    pool_pre_ping=True,

    # Evita mantener conexiones demasiado antiguas.
    # Neon recomienda reciclarlas periódicamente.
    pool_recycle=300,

    # No queremos que una petición quede bloqueada
    # demasiado tiempo esperando una conexión.
    pool_timeout=10,
)


SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

Base = declarative_base()


def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()