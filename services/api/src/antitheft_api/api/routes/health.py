from typing import Annotated

from fastapi import APIRouter, Depends

from antitheft_api import __version__
from antitheft_api.config import Settings, get_settings
from antitheft_api.schemas.health import HealthResponse

router = APIRouter(prefix="/health", tags=["health"])


@router.get("/live", response_model=HealthResponse, summary="Process liveness")
async def liveness(settings: Annotated[Settings, Depends(get_settings)]) -> HealthResponse:
    return HealthResponse(
        status="ok",
        service=settings.app_name,
        version=__version__,
        environment=settings.environment,
    )


@router.get("/ready", response_model=HealthResponse, summary="Application readiness")
async def readiness(settings: Annotated[Settings, Depends(get_settings)]) -> HealthResponse:
    # Database connectivity becomes a required readiness check when persistence is
    # introduced in Phase 3. Reporting "not_checked" is deliberate and truthful.
    return HealthResponse(
        status="ready",
        service=settings.app_name,
        version=__version__,
        environment=settings.environment,
        checks={"database": "not_checked_phase_0"},
    )
