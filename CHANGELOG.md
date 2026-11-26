# Changelog

Maintained by Daniel G. Cosenza from FNX Labs.

All notable changes to this image are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and image tags track
the upstream stable Redis 8.x release version.

## [8.12.0] - 2026-11-26

### Automated Daily Build
- Verified components: Redis `8.12.0`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: refreshed base OS, dependencies, and supply-chain attestations.
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/redis@sha256:44520075656931752a4842bd64bb73119b21313fa7238895c378d8164405b0f8` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
## [8.12.0] - 2026-11-25

### Automated Daily Build
- Verified components: Redis `8.12.0`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: refreshed base OS, dependencies, and supply-chain attestations.
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/redis@sha256:04d4d2373a33c536338838babbcf7b170fce5df2f503df4382c5416588b74dce` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
## [8.12.0] - 2026-11-25

### Changed

- Rebuilt on Debian `13.8` (`debian:trixie-slim`) with redis `8.12.0`.
- Verified `0` fixable CRITICAL/HIGH vulnerabilities in Trivy and Grype.
- Published digest: `dgcosenza/redis@sha256:6c95db306f62fb1b7bedab1bf1ddbb0ec3bb0e7caf8ce84b6f8817142299c7eb`.
## [8.12.0] - 2026-11-24

### Added

- Initial public build: Redis `8.12.0` compiled from official verified source
  on Debian 13 (trixie) slim with TLS (`BUILD_TLS=yes`), zstd replication
  compression (`BUILD_COMPRESSION=yes`), and jemalloc.
- Drop-in compatibility with official `redis:8` (`docker-entrypoint.sh`, `/data`
  working directory and volume, `redis` uid/gid `999:999`, `REDISCLI_AUTH`
  healthcheck support, `6379/tcp`).
- Non-root by default (`USER redis`), `tini` as PID 1, and pure-C `setpriv`
  privilege-drop support (no Go-based `gosu` dependency).
- Automated 7-step daily CI pipeline: upstream release check, clean `--no-cache`
  build, Trivy and Grype blocking gates, SPDX SBOM, functional and negative
  smoke tests, Docker Hub publishing, automated README/CHANGELOG sync, and
  failure alerting.
