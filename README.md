# Redis 8 for Debian 13 (trixie)

[![Daily build, scan and publish](https://github.com/dgcosenza/redis-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/redis-docker/actions/workflows/daily.yml)
[![Docker Hub pulls](https://img.shields.io/docker/pulls/dgcosenza/redis.svg)](https://hub.docker.com/r/dgcosenza/redis)
[![Image size](https://img.shields.io/docker/image-size/dgcosenza/redis/latest.svg)](https://hub.docker.com/r/dgcosenza/redis)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A hardened, continuously rebuilt **Debian 13 (trixie)** container image of
[Redis 8](https://redis.io/) compiled directly from official verified upstream
source releases with TLS (`BUILD_TLS=yes`), zstd replication compression
(`BUILD_COMPRESSION=yes`), and jemalloc.

It is a **drop-in replacement** for the official `redis:8` image: same
`docker-entrypoint.sh` conventions, `/data` working directory and volume,
`redis` service account (`999:999`), port `6379`, and `REDISCLI_AUTH`
environment authentication — while running **non-root by default** under `tini`
as PID 1.

## Current versions

<!-- versions:start -->

| Component | Resolved version |
|---|---|
| Base OS | Debian `13.8` (`debian:trixie-slim`) |
| `redis` | `8.12.0` |
| Last verified build | `2026-11-25` |
| Fixable CRITICAL / HIGH CVEs | `0` (Trivy + Grype gate) |
| Published digest | `dgcosenza/redis@sha256:6c95db306f62fb1b7bedab1bf1ddbb0ec3bb0e7caf8ce84b6f8817142299c7eb` |

Currently tracked unfixed upstream findings (no fix released): `CVE-2025-69720`, `CVE-2026-107494`, `CVE-2026-119373`, `CVE-2026-119374`, `CVE-2026-119379`, `CVE-2026-124709`, `CVE-2026-16742`, `CVE-2026-54369`, `CVE-2026-76642`, `CVE-2026-78408`.

<!-- versions:end -->

## Supported tags

| Tag | Meaning |
|---|---|
| `latest` | Newest successfully built, tested, and scanned Redis 8 image |
| `8` | Moving tag for the latest Redis 8.x stable build |
| `<redis-version>` | Specific upstream release, e.g. `8.12.0` (moves on daily rebuilds of that release) |
| `<redis-version>-<YYYYMMDD>` | Immutable date-stamped build of that release |
| `sha-<short>` | Immutable build of a specific repository commit |

Pin production deployments by digest:

```bash
docker pull dgcosenza/redis:latest
docker inspect --format='{{index .RepoDigests 0}}' dgcosenza/redis:latest
# image: dgcosenza/redis@sha256:...
```

## Quick start

```bash
docker run -d --name redis \
  --restart unless-stopped \
  --security-opt no-new-privileges:true \
  -e REDISCLI_AUTH='change-me' \
  dgcosenza/redis:latest \
  sh -c 'exec redis-server --requirepass "${REDISCLI_AUTH}"'
```

Verify connectivity:

```bash
docker exec redis sh -c 'redis-cli --no-auth-warning ping'
```

## Compose example

See [docker-compose.example.yml](docker-compose.example.yml) for a
production-style internal-network configuration with `REDISCLI_AUTH`,
`no-new-privileges:true`, resource limits, and authenticated healthcheck.

## Configuration

### Ports

| Port | Protocol | Purpose |
|---|---|---|
| `6379` | TCP | Redis client protocol (plain or TLS when configured) |

Keep Redis on an internal Docker network without publishing port `6379` to
untrusted interfaces.

### Volumes

| Path | Owner | Purpose |
|---|---|---|
| `/data` | `redis:redis` (`999:999`) | Working directory for RDB snapshots (`dump.rdb`) and AOF logs (`appendonlydir/`) |

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `REDISCLI_AUTH` | *(unset)* | Password automatically consumed by `redis-cli` (including the built-in healthcheck) and optionally forwarded to `--requirepass` |
| `TZ` | `UTC` | Timezone for log timestamps |
| `SKIP_DROP_PRIVS` | *(unset)* | When explicitly started as `--user 0`, skip privilege drop to `redis` |
| `SKIP_FIX_PERMS` | *(unset)* | When explicitly started as `--user 0`, skip repairing ownership on `/data` |

### UID / GID

The image defines `USER redis` (`uid=999`, `gid=999`), matching the official
`redis` image IDs. If an existing host bind mount at `/data` is owned by root,
either `chown 999:999` on the host before starting, or start with `--user 0`
so `docker-entrypoint.sh` repairs `/data` ownership and drops privileges to
`999:999` via `setpriv --no-new-privs`.

## Healthcheck

```text
sh -c "redis-cli --no-auth-warning ping | grep -qx PONG"
```

Requiring an exact `PONG` line ensures the healthcheck fails closed on
`NOAUTH`, `WRONGPASS`, or connection errors (`redis-cli` can exit `0` when
printing server error replies). When `REDISCLI_AUTH` is set in the container
environment, `redis-cli` authenticates automatically.

## Upgrading and migrating from official `redis:8`

1. If persistence is enabled, flush and back up `dump.rdb` / `appendonlydir/`
   (`docker exec <container> redis-cli --no-auth-warning BGSAVE` and copy
   `/data`).
2. Replace `redis:8.x` in your compose file with
   `dgcosenza/redis:<version>@sha256:<digest>`.
3. Recreate only the Redis service (`docker compose up -d redis`).
4. Confirm `healthy` status and verify dependent applications reconnect
   cleanly.

**Note on optional Redis 8 modules:** This image builds core Redis 8
(`redis-server`, `redis-cli`, `redis-sentinel`, `redis-benchmark`,
`redis-check-rdb`, `redis-check-aof`) with TLS and zstd compression, omitting
the optional bundled search/JSON/time-series/bloom Rust/C++ modules to keep the
image minimal and free of unrelated toolchain dependencies.

Rollback is immediate: restore the previous `redis:8.x@sha256:...` reference
and run `docker compose up -d redis` (restore your `dump.rdb` backup if
downgrading across minor versions that changed RDB format).

## Security

* **Base OS:** `debian:trixie-slim`, fully upgraded (`apt-get upgrade`) on
  every build with `--no-install-recommends` and cleaned APT lists.
* **Verified upstream source:** Official Redis release tarballs are fetched
  over HTTPS and verified against the official SHA-256 digests published in
  `redis/redis-hashes` prior to compilation.
* **Non-root & minimal attack surface:** Runs as `redis` (`999:999`) by default
  under `tini`; uses Debian `util-linux` `setpriv` instead of a separate Go
  binary; ships no compiler or package manager cache in the runtime stage.
* **Scan policy:** Every build must pass **Trivy** (`--ignore-unfixed`,
  `CRITICAL,HIGH`) and **Grype** (`--only-fixed`, severity `high`) with **0
  fixable CRITICAL or HIGH** vulnerabilities. Full scan reports and a Syft SPDX
  SBOM are retained for 90 days; Trivy SARIF is uploaded to GitHub code
  scanning.
* **Current status:** See the CI badge above and "Current versions".

## Building locally

```bash
git clone https://github.com/dgcosenza/redis-docker.git
cd redis-docker
docker build -t dgcosenza/redis:dev .
./tests/smoke.sh dgcosenza/redis:dev
```

Build arguments:

| Argument | Default | Purpose |
|---|---|---|
| `DEBIAN_VERSION` | `trixie-slim` | Debian 13 base tag |
| `REDIS_VERSION` | tracked release | Official Redis 8.x release version |
| `REDIS_SHA256` | pinned | Official SHA-256 digest from `redis/redis-hashes` |
| `REDIS_UID` / `REDIS_GID` | `999` / `999` | Unprivileged `redis` user/group IDs |
| `IMAGE_CREATED`, `IMAGE_REVISION`, `IMAGE_SOURCE` | empty / repo | OCI image metadata |

## Update policy

A GitHub Actions workflow (`.github/workflows/daily.yml`) runs **daily** (and on
every push to `main`, on pull requests, and on demand via `workflow_dispatch`),
gated first by `.github/workflows/public-check.yml`:

1. **Upstream check:** resolves the latest stable Redis 8.x release via the
   authenticated GitHub API (`GH_TOKEN`), fetches its official SHA-256 digest
   from `redis/redis-hashes`, diffs against `versions.json`, and captures
   release notes for newly published versions.
2. **Clean rebuild:** compiles Redis from verified source on `debian:trixie-slim`
   with `apt-get upgrade` and `--no-cache` on scheduled runs.
3. **Vulnerability fix and gate:** scans the candidate image with **Trivy**
   (table, JSON, SARIF to GitHub code scanning) and **Grype**; fails on any
   fixable **CRITICAL** or **HIGH** vulnerability, archives reports and an SPDX
   SBOM (Syft) for 90 days, and diffs findings against the prior build.
4. **Smoke test:** tests both default and `REDISCLI_AUTH`-authenticated startup,
   confirms non-root uid `999`, verifies `SET`/`GET`/`SAVE`, and asserts that
   wrong passwords and stopped servers fail the healthcheck.
5. **Publish:** on non-PR runs with Docker Hub credentials configured, pushes
   `latest`, `8`, `<version>`, `<version>-<YYYYMMDD>` (immutable), and
   `sha-<short>`, recording the published digest.
6. **Automated documentation sync:** when versions, base OS, digest, or CVE
   status change, commits updated `versions.json`, the README "Current
   versions" block, and a dated `CHANGELOG.md` entry (`[skip ci]`), then syncs
   the README and short description to Docker Hub.
7. **Alerting:** on failure of any job on a scheduled or `main` run, opens or
   updates a single GitHub issue labeled `ci-failure` with the failing job and
   run link, and closes it automatically on the next green run.

## Design decisions

* **Debian 13 slim multi-stage source build.** Matches upstream `redis:8-trixie`
  OS and ABI while separating the build toolchain completely from the final
  runtime layer and applying full `apt-get upgrade` daily.
* **Core Redis without optional Rust/C++ module bundle.** Keeps the image small,
  fast to rebuild daily, and free of unrelated search/JSON module CVEs for
  deployments using Redis as a cache, session store, or lock manager.
* **Non-root default (`USER redis`) with `setpriv` fallback.** Ensures even
  `sh -c 'exec redis-server ...'` command wrappers execute unprivileged without
  needing a Go-based `gosu` binary.
* **`tini` as PID 1.** Guarantees reliable `SIGTERM` delivery so Redis triggers
  a clean shutdown and RDB flush on container stop.

## License

The packaging, scripts, workflow, and documentation in this repository are
licensed under the **MIT License** (see [LICENSE](LICENSE)).

Redis 8 is tri-licensed under **AGPLv3**, RSALv2, and SSPLv1; this image elects
**GNU Affero General Public License v3 (`AGPL-3.0-only`)** for redistribution.
Upstream notices are preserved in `/usr/share/doc/redis-notices/` and detailed
in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Credits

* [Redis Open Source](https://github.com/redis/redis) — in-memory data store
* [docker-library/redis](https://github.com/redis/docker-library-redis) —
  jemalloc and container entrypoint conventions
* Container packaging, CI, and documentation: maintained by Daniel G. Cosenza from FNX Labs ([dgcosenza](https://github.com/dgcosenza))
