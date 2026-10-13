from typing import Literal

from pydantic import BaseModel, ConfigDict


class HealthResponse(BaseModel):
    model_config = ConfigDict(extra="forbid")

    status: Literal["ok", "ready"]
    service: str
    version: str
    environment: str
    checks: dict[str, str] | None = None
