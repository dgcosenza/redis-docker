# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Redis 8 (core server + CLI + sentinel) compiled from official source on
# Debian 13 (trixie) slim with TLS and zstd replication compression.
#
# Drop-in compatible with official redis:8: same docker-entrypoint.sh, /data
# volume, redis user (999:999), port 6379, REDISCLI_AUTH support, and default
# protected-mode behavior inside containers.
#
# Every version below is a documented default; CI overrides them with the
# latest stable Redis 8.x release on each run (.github/workflows/daily.yml).
# ---------------------------------------------------------------------------

ARG DEBIAN_VERSION=trixie-slim

ARG REDIS_VERSION=8.12.0
ARG REDIS_SHA256=b0100a879b2d45dc97d8fda941127609d648f8913008db1b65a2f72a8ae36c8b

ARG REDIS_UID=999
ARG REDIS_GID=999

ARG IMAGE_CREATED=""
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/redis-docker"

# ---- Stage 1: compile Redis 8 from verified official source ----------------
FROM debian:${DEBIAN_VERSION} AS builder

ARG REDIS_VERSION
ARG REDIS_SHA256

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y --no-install-recommends upgrade \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        dpkg-dev \
        libc6-dev \
        libssl-dev \
        libzstd-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/redis

RUN set -eux; \
    curl -fsSL --retry 3 "https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz" -o /tmp/redis.tar.gz; \
    echo "${REDIS_SHA256}  /tmp/redis.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/redis.tar.gz -C /usr/src/redis --strip-components=1; \
    rm -f /tmp/redis.tar.gz; \
    # Disable protected-mode default (matching official docker-library/redis)
    grep -E '^ *createBoolConfig[(]"protected-mode",.*, *1 *,.*[)],$' src/config.c; \
    sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' src/config.c; \
    grep -E '^ *createBoolConfig[(]"protected-mode",.*, *0 *,.*[)],$' src/config.c; \
    # Match Debian jemalloc page-size configuration
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    dpkgArch="$(dpkg --print-architecture)"; \
    extraJemalloc="--build=${gnuArch}"; \
    case "${dpkgArch##*-}" in \
        amd64|i386|x32) extraJemalloc="${extraJemalloc} --with-lg-page=12" ;; \
        *) extraJemalloc="${extraJemalloc} --with-lg-page=16" ;; \
    esac; \
    extraJemalloc="${extraJemalloc} --with-lg-hugepage=21"; \
    grep -F 'cd jemalloc && ./configure ' deps/Makefile; \
    sed -ri "s!cd jemalloc && ./configure !&${extraJemalloc} !" deps/Makefile; \
    grep -F "cd jemalloc && ./configure ${extraJemalloc} " deps/Makefile; \
    BUILD_TLS=yes BUILD_COMPRESSION=yes make -j"$(nproc)" all; \
    BUILD_TLS=yes BUILD_COMPRESSION=yes make install; \
    find /usr/local/bin -maxdepth 1 -type f -executable -exec strip '{}' +; \
    install -d /opt/notices; \
    for f in LICENSE.txt COPYING REDISCONTRIBUTIONS.txt; do \
        [ -f "$f" ] && install -m 0644 "$f" "/opt/notices/$f" || true; \
    done

# ---- Stage 2: hardened Debian 13 runtime -----------------------------------
FROM debian:${DEBIAN_VERSION}

ARG DEBIAN_VERSION
ARG REDIS_VERSION
ARG REDIS_UID
ARG REDIS_GID
ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_SOURCE

LABEL org.opencontainers.image.title="Redis 8 (Debian 13)" \
      org.opencontainers.image.description="Hardened, up-to-date Debian 13 (trixie) build of Redis 8 from official source with TLS and zstd compression, drop-in compatible with redis:8." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/redis" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${REDIS_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.licenses="AGPL-3.0-only" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      io.github.dgcosenza.redis.upstream_version="${REDIS_VERSION}" \
      io.github.dgcosenza.redis.base="debian:${DEBIAN_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    REDIS_VERSION=${REDIS_VERSION}

RUN apt-get update \
    && apt-get -y --no-install-recommends upgrade \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libssl3t64 \
        libzstd1 \
        tini \
        tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Fixed service account matching official redis image (999:999).
RUN groupadd --system --gid "${REDIS_GID}" redis \
    && useradd --system --uid "${REDIS_UID}" --gid redis \
        --home-dir /data --no-create-home --shell /usr/sbin/nologin redis \
    && install -d -o redis -g redis -m 0750 /data

COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /opt/notices/ /usr/share/doc/redis-notices/
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN redis-server --version && redis-cli --version

VOLUME /data
WORKDIR /data

USER redis
EXPOSE 6379

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD ["sh", "-c", "redis-cli --no-auth-warning ping | grep -qx PONG"]

ENTRYPOINT ["/usr/bin/tini", "--", "docker-entrypoint.sh"]
CMD ["redis-server"]
