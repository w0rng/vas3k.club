FROM node:14 as frontend

WORKDIR /app
COPY ./src/frontend .

RUN npm install && npm run build && npm prune --production && rm -rf node_modules


FROM python:3.8-slim-buster

RUN apt-get update \
    && apt-get install --no-install-recommends -yq \
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
COPY --from=frontend /app ./frontend
