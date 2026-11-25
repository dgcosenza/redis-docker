#!/bin/sh
# Drop-in entrypoint for dgcosenza/redis (compatible with official redis:8).
# Runs non-root by default (USER redis). If explicitly started as root (e.g.
# with `--user 0` to repair volume permissions), fixes /data ownership and
# drops privileges via Debian util-linux `setpriv` (no Go dependency).
set -e

# First arg is `-f` or `--some-option`, or `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
  set -- redis-server "$@"
fi

# Drop privileges if started as root for redis-server / redis-sentinel
if [ "$(id -u)" = "0" ] && [ -z "${SKIP_DROP_PRIVS:-}" ]; then
  case "$1" in
    redis-server|redis-sentinel|/usr/local/bin/redis-server|/usr/local/bin/redis-sentinel)
      if [ -z "${SKIP_FIX_PERMS:-}" ] && [ -d /data ]; then
        find /data \! -user redis -exec chown redis:redis '{}' + 2>/dev/null || true
      fi
      exec /usr/bin/setpriv --reuid=redis --regid=redis --clear-groups --no-new-privs -- "$0" "$@"
      ;;
  esac
fi

# Restrict default umask for RDB/AOF files (matches upstream docker-library/redis)
um="$(umask)"
if [ "$um" = "0022" ]; then
  umask 0077
fi

exec "$@"
