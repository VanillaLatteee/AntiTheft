from fastapi.testclient import TestClient

from antitheft_api.main import create_app


def test_liveness_reports_service_without_dependency_details() -> None:
    with TestClient(create_app()) as client:
        response = client.get("/health/live", headers={"X-Request-ID": "test-request"})

    assert response.status_code == 200
    assert response.headers["X-Request-ID"] == "test-request"
    assert response.json() == {
        "status": "ok",
        "service": "AntiTheft API",
        "version": "0.1.0",
        "environment": "development",
        "checks": None,
    }


def test_readiness_is_explicit_about_phase_zero_database_check() -> None:
    with TestClient(create_app()) as client:
        response = client.get("/health/ready")

    assert response.status_code == 200
    assert response.json()["status"] == "ready"
    assert response.json()["checks"] == {"database": "not_checked_phase_0"}
    assert response.headers["X-Request-ID"]


def test_unknown_route_returns_not_found() -> None:
    with TestClient(create_app()) as client:
        response = client.get("/does-not-exist")

    assert response.status_code == 404
