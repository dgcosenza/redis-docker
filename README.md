# Redis 8 for Debian 13 (trixie-slim)

[![Daily Redis image](https://github.com/dgcosenza/redis-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/redis-docker/actions/workflows/daily.yml)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue.svg)](https://github.com/dgcosenza/redis-docker/blob/main/LICENSE)
[![Upstream License: AGPL-3.0-only](https://img.shields.io/badge/upstream-AGPL--3.0--only-green.svg)](https://github.com/redis/redis/blob/unstable/LICENSE.txt)
[![Signed with Cosign](https://img.shields.io/badge/signed-cosign%20OIDC-blueviolet.svg)](#supply-chain-verification)
[![SLSA Level 3](https://img.shields.io/badge/SLSA-Level%203-brightgreen.svg)](#supply-chain-verification)
[![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational.svg)](#supported-architectures)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/redis-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/redis-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/redis)](https://hub.docker.com/r/dgcosenza/redis)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/redis/latest)](https://hub.docker.com/r/dgcosenza/redis)
[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/redis-docker?label=version)](https://github.com/dgcosenza/redis-docker/releases)

A source-built, multi-arch, rootless **Debian 13 (`trixie-slim`)** container image of [Redis 8](https://redis.io/) with TLS (`BUILD_TLS=yes`), zstd replication compression (`BUILD_COMPRESSION=yes`), and jemalloc, maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub:** [`dgcosenza/redis`](https://hub.docker.com/r/dgcosenza/redis)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/redis`](https://github.com/dgcosenza/redis-docker/pkgs/container/redis) (identical signed multi-arch digest)
- **Source Repository:** [`dgcosenza/redis-docker`](https://github.com/dgcosenza/redis-docker)
- **Upstream Application:** [`redis/redis`](https://github.com/redis/redis) (`AGPL-3.0-only` elected from Redis 8 tri-license)

---

## Overview

`dgcosenza/redis` compiles official SHA-256-verified Redis 8 source releases on **Debian 13 (`trixie-slim`)** for both `linux/amd64` and `linux/arm64`:

- **Drop-in replacement for official `redis:8`:** Preserves `docker-entrypoint.sh`, `/data` volume, `redis` (`999:999`), port `6379`, and `REDISCLI_AUTH` authentication — while running **non-root by default** under `tini`.
- **Rootless & read-only rootfs ready:** Verified natively on both architectures under `--read-only --cap-drop ALL --security-opt no-new-privileges:true`.
- **Hardened supply chain:** Hadolint + Gitleaks preflight, native multi-arch smoke tests, strict Dive efficiency gate (`>= 95%`, `<= 5%` wasted), Syft SPDX + CycloneDX SBOMs, Trivy + Grype (SBOM) zero-fixable all-severity gates, Cosign keyless OIDC signatures & SBOM attestations, SLSA Build L3 provenance, dual-registry publishing, and signed GitHub Releases.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| Redis | `8.12.0` |
| Base OS | `Debian 13.8 (trixie-slim)` |
| Architectures | `linux/amd64, linux/arm64` |
| Compressed size (per arch) | `amd64: 35.5 MB, arm64: 35.9 MB` |
| Last verified build (UTC) | `2026-11-26` |
| Published multi-arch digest | `dgcosenza/redis@sha256:7bb839d56d2c47f8b1fde8b62b75e616ccea90c28d2f7e9fbee4f227594d28cf` |
| GHCR mirror | `ghcr.io/dgcosenza/redis@sha256:7bb839d56d2c47f8b1fde8b62b75e616ccea90c28d2f7e9fbee4f227594d28cf` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (13 upstream-unfixed) |

Currently tracked upstream-unfixed findings (no fix released): `CVE-2025-69720`, `CVE-2026-107494`, `CVE-2026-119373`, `CVE-2026-119374`, `CVE-2026-119379`, `CVE-2026-124709`, `CVE-2026-16742`, `CVE-2026-54369`, `CVE-2026-76642`, `CVE-2026-78408` (+3 more in CI artifacts).
<!-- versions:end -->

---

## Supported Tags & Tag Policy

Identical multi-arch OCI digests are published to **Docker Hub** (`dgcosenza/redis`) and **GHCR** (`ghcr.io/dgcosenza/redis`), accompanied by an automated signed [GitHub Release](https://github.com/dgcosenza/redis-docker/releases):

| Tag | Policy | Description |
| --- | --- | --- |
| `<version>-<YYYYMMDD>` (e.g. `8.12.0-20261125`) | **Immutable** | Date-stamped daily rebuild pinning the Redis release and UTC build date. |
| `sha-<short>` | **Immutable** | Packaging repository Git commit tag. |
| `<version>` (e.g. `8.12.0`) | Moving | Latest verified Debian 13 security rebuild of that Redis release. |
| `8` | Moving | Latest verified Redis 8.x stable build. |
| `latest` | Moving | Latest verified build tracking the newest official Redis 8 release. |

**Production pinning:** Pin by immutable digest:

```yaml
image: dgcosenza/redis:8.12.0@sha256:<digest>
# or via GitHub Container Registry (identical digest):
image: ghcr.io/dgcosenza/redis:8.12.0@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Verification |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Compiled with jemalloc `lg-page=12`, smoke-tested (`--read-only --cap-drop ALL`), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native x86_64 CI runners. |
| `linux/arm64` | **Published & natively tested** | Compiled with jemalloc `lg-page=16`, smoke-tested (`--read-only --cap-drop ALL`), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native ARM64 CI runners. |

---

## Quick Start

### `docker run` (hardened, rootless, read-only)

```bash
docker run -d --name redis \
  --restart unless-stopped \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --tmpfs /tmp:noexec,nosuid,size=16m \
  -v redis_data:/data \
  -e REDISCLI_AUTH='change-me' \
  dgcosenza/redis:latest \
  sh -c 'exec redis-server --requirepass "${REDISCLI_AUTH}"'
```

Verify connectivity:

```bash
docker exec redis sh -c 'redis-cli --no-auth-warning ping'
```

### Hardened Docker Compose

See [`docker-compose.example.yml`](https://github.com/dgcosenza/redis-docker/blob/main/docker-compose.example.yml) for a hardened compose definition running rootless with `read_only: true`, `cap_drop: [ALL]`, `no-new-privileges:true`, an internal network, and an authenticated healthcheck.

---

## Configuration

### Ports & Volumes

| Resource | Details | Purpose |
| --- | --- | --- |
| `6379/tcp` | Internal network | Redis client protocol (plain or TLS when configured) |
| `/data` | Owner `redis:redis` (`999:999`) | Working directory for RDB snapshots (`dump.rdb`) and AOF logs (`appendonlydir/`) |

### Environment Variables

| Variable | Default | Description |
| --- | --- | --- |
| `REDISCLI_AUTH` | *(unset)* | Password automatically used by `redis-cli` (and built-in healthcheck) and optionally passed to `--requirepass` |
| `TZ` | `UTC` | Timezone for log timestamps |
| `SKIP_DROP_PRIVS` | *(unset)* | When explicitly started as `--user 0`, skip privilege drop to `redis` |
| `SKIP_FIX_PERMS` | *(unset)* | When explicitly started as `--user 0`, skip repairing ownership on `/data` |

### UID / GID

The image defaults to `USER redis` (`999:999`). If an existing host bind mount at `/data` is owned by root, either `chown 999:999` on the host before starting, or start once with `--user 0` so `docker-entrypoint.sh` fixes ownership and drops privileges via `setpriv --no-new-privs`.

---

## Healthcheck

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD ["sh", "-c", "redis-cli --no-auth-warning ping | grep -qx PONG"]
```

Requiring an exact `PONG` line guarantees fail-closed detection on `NOAUTH`, `WRONGPASS`, or connection errors.

---

## Upgrading and Migrating from official `redis:8`

1. If persistence is enabled, flush and back up `/data` (`docker exec <container> redis-cli --no-auth-warning BGSAVE`).
2. Replace `redis:8.x` with `dgcosenza/redis:<version>@sha256:<digest>` (or `ghcr.io/dgcosenza/redis:<version>@sha256:<digest>`).
3. Recreate only the Redis service (`docker compose up -d redis`) and confirm `healthy` status plus dependent service reconnection.

**Note on optional Redis 8 modules:** This image builds core Redis 8 (`redis-server`, `redis-cli`, `redis-sentinel`, `redis-benchmark`, `redis-check-rdb`, `redis-check-aof`) with TLS and zstd compression, omitting optional Rust/C++ search/JSON/time-series/bloom modules to keep the attack surface minimal.

---

## Supply-Chain Verification

Every published digest (multi-arch index and per-architecture manifests) on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/redis-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/redis:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/redis-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/redis:latest
```

### Verify SPDX / CycloneDX SBOM attestations

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/redis-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/redis@sha256:<arch-digest>
```

### Verify SLSA Build Provenance

```bash
gh attestation verify oci://ghcr.io/dgcosenza/redis:latest --owner dgcosenza
```

---

## Security

- **Preflight gates:** Every push and PR runs **Hadolint** (blocking on warning+), **Gitleaks** secret scanning across git history, and **public-content/attribution/license** checks.
- **Verified upstream source:** Official Redis tarballs are verified against SHA-256 hashes from `redis/redis-hashes` before compiling.
- **Rootless & minimal attack surface:** Defaults to `USER redis` (`999:999`), verified with `--read-only` and `--cap-drop ALL`, uses `util-linux` `setpriv` instead of Go-based `gosu`.
- **Vulnerability & efficiency gates (all severities with a fix):** Each architecture generates **Syft** SPDX + CycloneDX SBOMs, passes a strict **Dive** efficiency gate (`>= 95%`, `<= 5%` wasted), and must pass **Trivy** (table, JSON, SARIF to Code Scanning, blocking `--ignore-unfixed`) and **Grype** scanning the SPDX SBOM (`--only-fixed --fail-on negligible`) with **0 fixable vulnerabilities of any severity**.
- **Dependency automation:** Renovate (`renovate.json`) pins base image digests and GitHub Action commit SHAs; Dependabot security alerts and OpenSSF Scorecard monitoring are enabled.
- See [`SECURITY.md`](https://github.com/dgcosenza/redis-docker/blob/main/SECURITY.md) for vulnerability reporting.

---

## Build Locally

```bash
git clone https://github.com/dgcosenza/redis-docker.git
cd redis-docker

docker buildx build \
  --platform linux/amd64 \
  --load \
  --build-arg IMAGE_CREATED="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg IMAGE_REVISION="$(git rev-parse HEAD)" \
  -t dgcosenza/redis:local \
  .

./tests/smoke.sh dgcosenza/redis:local
```

| Build Arg | Default | Purpose |
| --- | --- | --- |
| `DEBIAN_BASE` | `debian:trixie-slim@sha256:...` | Digest-pinned Debian 13 base image (refreshed daily by CI) |
| `REDIS_VERSION` | `8.12.0` | Official Redis 8.x release version |
| `REDIS_SHA256` | pinned | Official SHA-256 digest from `redis/redis-hashes` |
| `REDIS_UID` / `REDIS_GID` | `999` / `999` | Unprivileged `redis` user/group IDs |

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/redis-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **05:30 UTC**, on pushes to `main`, on pull requests (verification only), and via `workflow_dispatch`:

1. **Preflight & upstream check:** Runs public-content checks, **Hadolint**, and **Gitleaks**; resolves the latest stable Redis 8.x release via authenticated GitHub API, fetches its official SHA-256 from `redis/redis-hashes`, resolves the latest `debian:trixie-slim` digest, diffs against `versions.json`, and emits `upstream-changes.md`.
2. **Multi-arch no-cache rebuild:** Compiles Redis natively on `linux/amd64` and `linux/arm64` runners with `--no-cache` on schedule and full Debian 13 `apt-get upgrade`.
3. **Smoke, Dive & vulnerability gates:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/redis-docker/blob/main/tests/smoke.sh) natively on both architectures (`--read-only --cap-drop ALL`, plain + `REDISCLI_AUTH`, `SET`/`GET`/`SAVE`, negative tests), enforces the strict **Dive** efficiency gate (`>= 95%`, `<= 5%` wasted), generates **Syft** SPDX + CycloneDX SBOMs, and gates publication on **0 fixable findings of any severity** in both **Trivy** and **Grype** (SBOM scan).
4. **Dual-registry publish & signing:** Assembles the multi-arch OCI index on **GHCR** (`ghcr.io/dgcosenza/redis`) and mirrors the identical digest to **Docker Hub** (`dgcosenza/redis`) with tags `latest`, `8`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>`; keyless-signs digests and attaches SPDX/CycloneDX SBOM attestations via **Cosign** OIDC; emits **SLSA Build L3** provenance; and publishes a signed **GitHub Release**.
5. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry via `github-actions[bot]` (`[skip ci]`), then syncs the Docker Hub overview and short description.
6. **Failure alerting:** Opens or updates a single GitHub issue labeled `ci-failure` on any `main` or scheduled failure, and closes it automatically on the next green run.

---

## Design Decisions

- **Debian 13 (`trixie-slim`) multi-stage source build:** Separates the build toolchain completely from runtime and applies daily Debian security upgrades.
- **Two-layer zero-waste runtime layout:** Upgrading Debian 13 inside an `os-base` stage and assembling the final image with cleanly separated OS and compiled-binary layers eliminates overwritten base-layer files so Dive remains at ~100% efficiency and ~0% wasted space across daily security rebuilds.
- **Core Redis without optional Rust/C++ modules:** Keeps the image compact, fast to rebuild, and free of unrelated module CVEs for cache/session/lock workloads.
- **Hadolint `DL3008` ignore:** Daily `--no-cache` security rebuilds intentionally pull the newest Debian 13 security updates via `apt-get` rather than pinning stale package versions.

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, entrypoint, CI workflows, scripts, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/redis-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Bundled upstream software — Redis 8 (`upstream: AGPL-3.0-only`):** Redis 8 is tri-licensed under AGPLv3, RSALv2, and SSPLv1; this image elects the [GNU Affero General Public License v3 (`AGPL-3.0-only`)](https://github.com/redis/redis/blob/unstable/LICENSE.txt).

Full notices are preserved inside the image (`/usr/share/doc/redis-notices/`) and in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/redis-docker/blob/main/THIRD-PARTY-NOTICES.md).

---

## Credits

- [Redis Open Source](https://github.com/redis/redis) and [docker-library/redis](https://github.com/redis/docker-library-redis)
- Container packaging, CI, and documentation: maintained by **Daniel G. Cosenza from FNX Labs** ([dgcosenza](https://github.com/dgcosenza))
