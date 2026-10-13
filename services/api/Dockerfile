FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY services/api/pyproject.toml services/api/README.md ./
COPY services/api/src ./src
RUN python -m pip install --upgrade pip && python -m pip install .

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "antitheft_api.main:app", "--host", "0.0.0.0", "--port", "8000"]

