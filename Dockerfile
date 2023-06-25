FROM node:18-slim as frontend_builder

WORKDIR /app
COPY ./src/frontend .
RUN npm install && ./node_modules/.bin/webpack --mode production


FROM caddy:2.3.0-alpine as caddy

COPY --from=frontend_builder /app/static /static
COPY ./etc/Caddyfile /etc/caddy/Caddyfile

FROM python:3.8-slim-buster

RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get update \
    && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install --no-install-recommends -yq \
      build-essential \
      libpq-dev \
      gdal-bin \
      libgdal-dev \
      make \
      cron \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY etc/crontab /etc/crontab
RUN chmod 600 /etc/crontab

COPY ./requirements.txt .
RUN pip3 install -r requirements.txt

COPY src .
COPY Makefile .
COPY --from=frontend_builder /app ./frontend
