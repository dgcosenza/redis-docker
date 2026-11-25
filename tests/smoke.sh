#!/usr/bin/env bash
# Smoke test for dgcosenza/redis.
#
# Verifies default unauthenticated run, live-parity authenticated run via
# REDISCLI_AUTH, non-root execution (uid 999), read/write/persistence, healthcheck,
# and negative checks (wrong password + stopped server).
#
# Usage: tests/smoke.sh [image]
#        IMAGE=dgcosenza/redis:latest tests/smoke.sh
set -euo pipefail

IMAGE="${1:-${IMAGE:-dgcosenza/redis:latest}}"
NAME_PLAIN="${NAME_PLAIN:-redis-smoke-plain}"
NAME_AUTH="${NAME_AUTH:-redis-smoke-auth}"

cleanup() {
  docker rm -f "$NAME_PLAIN" "$NAME_AUTH" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "== 1. Default run (non-root, healthcheck, SET/GET, SAVE)"
docker run -d --name "$NAME_PLAIN" \
  --security-opt no-new-privileges:true \
  "$IMAGE"

for _ in $(seq 1 30); do
  status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$NAME_PLAIN")"
  [ "$status" = "healthy" ] && break
  [ "$status" = "unhealthy" ] && { docker logs "$NAME_PLAIN"; exit 1; }
  sleep 2
done
test "$(docker inspect -f '{{.State.Health.Status}}' "$NAME_PLAIN")" = "healthy"
test "$(docker exec "$NAME_PLAIN" id -u)" = "999"
test "$(docker exec "$NAME_PLAIN" id -g)" = "999"
test "$(docker exec "$NAME_PLAIN" redis-cli SET smoke:key ok)" = "OK"
test "$(docker exec "$NAME_PLAIN" redis-cli GET smoke:key)" = "ok"
test "$(docker exec "$NAME_PLAIN" redis-cli SAVE)" = "OK"
docker exec "$NAME_PLAIN" test -f /data/dump.rdb

echo "== 2. Authenticated run (REDISCLI_AUTH + sh -c --requirepass parity)"
docker run -d --name "$NAME_AUTH" \
  --security-opt no-new-privileges:true \
  -e REDISCLI_AUTH=ci-smoke-secret \
  "$IMAGE" \
  sh -c 'exec redis-server --requirepass "${REDISCLI_AUTH}"'

for _ in $(seq 1 30); do
  status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$NAME_AUTH")"
  [ "$status" = "healthy" ] && break
  [ "$status" = "unhealthy" ] && { docker logs "$NAME_AUTH"; exit 1; }
  sleep 2
done
test "$(docker inspect -f '{{.State.Health.Status}}' "$NAME_AUTH")" = "healthy"
test "$(docker exec "$NAME_AUTH" id -u)" = "999"
docker exec "$NAME_AUTH" sh -c 'redis-cli --no-auth-warning ping | grep -qx PONG'

echo "== 3. Negative test: wrong password must fail healthcheck"
if docker exec -e REDISCLI_AUTH=wrong-pass "$NAME_AUTH" sh -c 'redis-cli --no-auth-warning ping | grep -qx PONG'; then
  echo "ERROR: healthcheck succeeded with wrong password" >&2
  exit 1
fi

echo "== 4. Negative test: stopped Redis fails healthcheck"
docker stop -t 2 "$NAME_AUTH" >/dev/null
if docker exec "$NAME_AUTH" sh -c 'redis-cli --no-auth-warning ping | grep -qx PONG' >/dev/null 2>&1; then
  echo "ERROR: healthcheck succeeded on stopped container" >&2
  exit 1
fi

echo "== 5. Version check"
docker exec "$NAME_PLAIN" redis-server --version

echo "Smoke test passed."
