# Third-party notices

This image compiles and packages Redis 8 from the official upstream source
release. The MIT license in `LICENSE` applies only to the container packaging,
scripts, CI workflow, and documentation maintained by Daniel G. Cosenza from FNX Labs.

| Component | Version | License | Source |
|---|---|---|---|
| Redis Open Source | 8.12.0 | AGPL-3.0-only (selected from Redis 8 tri-license: AGPLv3 / RSALv2 / SSPLv1) | https://github.com/redis/redis |
| jemalloc (bundled with Redis) | 5.3.0 | BSD-2-Clause | https://github.com/jemalloc/jemalloc |
| Debian 13 runtime libraries | trixie | Debian Free Software Guidelines (DFSG) | https://www.debian.org/ |

## Redis 8 Tri-License and AGPLv3 Redistribution Compliance

Starting with Redis 8.0, Redis Open Source is offered under a tri-license
allowing recipients to choose among **GNU Affero General Public License v3
(AGPLv3)**, RSALv2, or SSPLv1. This container image elects **GNU AGPLv3** for
redistribution:

* Upstream source tarballs are downloaded unmodified from
  `https://download.redis.io/releases/` and verified against the official
  SHA-256 hashes published in `redis/redis-hashes`.
* Only the standard Docker-library compile adjustments (`protected-mode`
  default and Debian-compatible jemalloc page-size flags) are applied during
  the build, and those exact instructions are publicly published in this
  repository's `Dockerfile`.
* The upstream `LICENSE.txt` and `COPYING` files are preserved inside the image
  under `/usr/share/doc/redis-notices/`.
* Complete corresponding source is available from
  <https://github.com/redis/redis> (at the tagged release version recorded in
  image labels and `versions.json`) together with this repository.

Redis is a registered trademark of Redis Ltd. This image is an independent
build and is not endorsed by or affiliated with Redis Ltd.
