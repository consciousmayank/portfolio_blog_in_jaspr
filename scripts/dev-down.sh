#!/usr/bin/env bash
# scripts/dev-down.sh — stop the local dev stack started by dev-up.sh.
#
# Usage:
#   scripts/dev-down.sh              # stop containers, keep Postgres volume
#   scripts/dev-down.sh --volumes    # stop AND delete the pgdata volume (full reset)
#   scripts/dev-down.sh --nuke       # everything: containers + volumes + .env + edge network

set -euo pipefail

cd "$(dirname "$0")/.."

BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
ok()   { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
step() { printf '\n%s== %s ==%s\n' "$BOLD" "$*" "$RESET"; }

COMPOSE=(docker compose -f docker-compose.yml -f docker-compose.dev.yml)

DOWN_ARGS=(down --remove-orphans)
WIPE_ENV=0
WIPE_NET=0

for arg in "$@"; do
  case "$arg" in
    --volumes|-v) DOWN_ARGS+=(--volumes) ;;
    --nuke)       DOWN_ARGS+=(--volumes); WIPE_ENV=1; WIPE_NET=1 ;;
    --help|-h)
      cat <<EOF
Usage: $0 [--volumes|--nuke]
  (no args)    stop containers, keep Postgres data
  --volumes    stop containers AND delete pgdata volume
  --nuke       --volumes + delete .env + drop the 'edge' docker network
EOF
      exit 0
      ;;
    *) warn "unknown flag: $arg (ignored)" ;;
  esac
done

step "Stopping stack"
"${COMPOSE[@]}" "${DOWN_ARGS[@]}"
ok "Containers stopped"

if [ "$WIPE_ENV" = "1" ]; then
  step "Removing .env"
  rm -f .env && ok "Deleted .env"
fi

if [ "$WIPE_NET" = "1" ]; then
  step "Removing 'edge' docker network"
  if docker network inspect edge >/dev/null 2>&1; then
    # Will fail if other (non-portfolio) projects still attach to it — that's fine.
    if docker network rm edge >/dev/null 2>&1; then
      ok "Network 'edge' removed"
    else
      warn "Network 'edge' is still in use by other containers — left in place"
    fi
  else
    ok "Network 'edge' already gone"
  fi
fi

printf '\n%sStack is down.%s\n' "$GREEN$BOLD" "$RESET"
