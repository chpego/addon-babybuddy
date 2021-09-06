ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:5.0.0
#hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual .build-dependencies \
    build-base=0.5-r2 \
    curl \
    jpeg-dev \
    libffi-dev \
    postgresql-dev \
    python3-dev=3.9.5-r1 \
    zlib-dev \
    nginx=1.20.1-r3

# add Nginx
# hadolint ignore=DL3009
RUN \
    rm -f -r \
        /etc/nginx \
    \
    && mkdir -p /var/log/nginx \
    && touch /var/log/nginx/error.log


RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    jpeg \
    libffi \
    libpq \
    py3-pip \
    python3

RUN \
  echo "**** downloading babybuddy ****" && \
  curl -o \
    /tmp/babybuddy.tar.gz -L \
    "https://github.com/babybuddy/babybuddy/archive/refs/tags/v1.8.2.tar.gz" && \
  mkdir -p /app/babybuddy && \
  tar xf \
    /tmp/babybuddy.tar.gz -C \
    /app/babybuddy --strip-components=1 

RUN \
  echo "**** installing babybuddy ****" && \
  cd /app/babybuddy && \
  pip3 install -U --no-cache-dir \
    pip && \
  pip install -U --ignore-installed -r requirements.txt

RUN \
  echo "**** cleanup ****" && \
  apk del --purge \
    .build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/.cache

COPY root/ /

# Build arguments
#ARG BUILD_ARCH
#ARG BUILD_DATE
#ARG BUILD_DESCRIPTION
#ARG BUILD_NAME
#ARG BUILD_REF
#ARG BUILD_REPOSITORY
#ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \