FROM python:3.9.13-slim-buster

# fixed permissions of files created by Docker:
ARG UID
ARG GID
ENV UID=${UID:-1000}
ENV GID=${GID:-1000}

ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PYTHONDONTWRITEBYTECODE=1 \
  # pip:
  PIP_NO_CACHE_DIR=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1 \
  PIP_DEFAULT_TIMEOUT=100 \
  # dockerize:
  DOCKERIZE_VERSION=v0.6.1 \
  # poetry:
  POETRY_VERSION=1.2.2 \
  POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=false \
  POETRY_CACHE_DIR="/var/cache/pypoetry" \
  POETRY_HOME="/usr/local" \
  TINI_VERSION=v0.19.0

# add tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# System deps (we don"t use exact versions because it is hard to update them,
# pin when needed):
# hadolint ignore=DL3008
RUN apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y \
    curl \
    # bash \
    # brotli \
    # The following packages are necessary to install psycopg2
    build-essential \
    libpq-dev \
    # gettext \
    # git \
    postgresql \
  # make tini executable
  && chmod +x /tini \
  # Installing `dockerize` utility:
  # https://github.com/jwilder/dockerize
  && curl -sSLO "https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" \
  && tar -C /usr/local/bin -xzvf "dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" \
  && rm "dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" && dockerize --version \
  # Installing `poetry` package manager:
  # https://github.com/python-poetry/poetry
  && curl -sSL "https://install.python-poetry.org" | python - \
  && poetry --version \
  # Cleaning cache:
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get clean -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN groupadd -g "${GID}" -r web \
  && useradd -d "/app" -g web -l -r -u "${UID}" web \
  && chown web:web -R "/app" 

# Copy only requirements, to cache them in docker layer
COPY --chown=web:web ./poetry.lock ./pyproject.toml /app/

# Project initialization:
RUN poetry version \
  # Install deps:
  && poetry run pip install -U pip \
  && poetry install --no-interaction --no-ansi

COPY ./entrypoint.sh /docker-entrypoint.sh

# Setting up proper permissions:
RUN chmod +x "/docker-entrypoint.sh"

# Running as non-root user:
USER web

# We customize how our app is loaded with the custom entrypoint:
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]