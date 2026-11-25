# Security policy

Maintainer: Daniel G. Cosenza from FNX Labs.

## Supported versions

Only the `latest`, `8`, and newest `<redis-version>` tags are supported. The
image is rebuilt daily from `debian:trixie-slim` with a full `apt-get upgrade`
and freshly compiled official Redis 8.x source whenever a new stable release is
published.

## Reporting a vulnerability

Open a private security advisory at
<https://github.com/dgcosenza/redis-docker/security/advisories/new>. Please do
not open a public issue for an undisclosed vulnerability.

## What this repository covers

This repository owns the packaging layer: the Dockerfile, entrypoint, smoke
tests, CI workflow, and published tags. Vulnerabilities in Redis itself should
also be reported upstream via <https://github.com/redis/redis/security>.

## Scanning and gates

* **Trivy:** the build fails on any fixable **CRITICAL** or **HIGH** finding
  across OS packages and libraries. Full reports are attached as 90-day
  artifacts and SARIF results are uploaded to GitHub code scanning.
* **Grype:** runs as a blocking gate (`--only-fixed`, severity high/critical),
  with reports archived for 90 days.
* **SBOM:** an SPDX JSON software bill of materials is generated with Syft and
  archived for 90 days.
* **Non-root execution:** the image runs as unprivileged user `redis`
  (`999:999`) by default, with `setpriv` privilege-drop fallback if started as
  root to repair mounted `/data` ownership.

## Hardening recommendations

* Pin production deployments by `@sha256:<digest>`.
* Run with `security_opt: [no-new-privileges:true]`.
* Keep Redis on an internal Docker network without publishing port `6379` to
  untrusted hosts, and require authentication (`--requirepass` or ACLs) with
  `REDISCLI_AUTH` supplied via `.env` or Docker secrets.
