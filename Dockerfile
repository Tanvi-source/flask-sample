# Dockerfile
# stage: build wheel (optional)
FROM python:3.11-slim AS build
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN apt-get update && apt-get install -y --no-install-recommends build-essential gcc && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN python -m pip install --upgrade pip wheel setuptools
RUN pip wheel --no-deps --wheel-dir=/wheels -r requirements.txt
COPY . .

# stage: runtime
FROM python:3.11-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY --from=build /wheels /wheels
RUN python -m pip install --upgrade pip && pip install --no-index --find-links=/wheels -r requirements.txt
COPY --from=build /app /app
EXPOSE 5000
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:5000", "--workers", "2"]
