# Changelog

Maintained by Daniel G. Cosenza from FNX Labs.

All notable changes to this image are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and image tags track
the upstream stable Redis 8.x release version.

## [8.12.0] - 2026-11-25

### Changed

- Rebuilt on Debian `13.8` (`debian:trixie-slim`) with redis `8.12.0`.
- Verified `0` fixable CRITICAL/HIGH vulnerabilities in Trivy and Grype.

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
