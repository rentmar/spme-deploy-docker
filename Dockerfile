FROM python:3.11-bookworm

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libmariadb-dev \
    netcat-openbsd \
    graphviz \
    libgraphviz-dev \
    pkg-config \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalar dependencias Python
COPY ./spmbe_backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn mysqlclient

# Copiar el proyecto
COPY ./spmbe_backend /app

# Puerto expuesto
EXPOSE 8000

# Script de entrada
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]