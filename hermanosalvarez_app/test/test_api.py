from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["mensaje"] == "API funcionando 🚀"


def test_paradas():
    response = client.get("/paradas")
    assert response.status_code == 200

    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0
    assert "id" in data[0]
    assert "nombre" in data[0]
    assert "bajoDemanda" in data[0]


def test_destinos_validos():
    response = client.get(
        "/destinos-validos",
        params={"origen": "toledo_hu", "dia": "laborable"},
    )
    assert response.status_code == 200

    data = response.json()
    assert isinstance(data, list)


def test_horarios_validos():
    response = client.get(
        "/horarios",
        params={
            "origen": "toledo_hu",
            "destino": "torrijos",
            "dia": "laborable",
        },
    )
    assert response.status_code == 200

    data = response.json()
    assert "horarios" in data
    assert isinstance(data["horarios"], list)


def test_horarios_inexistentes():
    response = client.get(
        "/horarios",
        params={
            "origen": "almorox",
            "destino": "toledo_hu",
            "dia": "laborable",
        },
    )
    assert response.status_code == 200

    data = response.json()
    assert "horarios" in data
    assert data["horarios"] == []