#!/bin/bash
# start-labspace.sh - Launch the Kubernetes Labspace
#
# Prerequisites (automatically checked on startup):
#
#   macOS:
#     brew install ttyd
#     Docker Desktop with Kubernetes enabled
#
#   Linux:
#     sudo apt install ttyd
#     Docker Desktop with Kubernetes enabled
#
#   If any prerequisite is missing, this script will tell you
#   exactly what to install and exit cleanly.

set -e

TTYD_PORT=8085
COMPOSE_FILE="compose.override.yaml"

# ── Color helpers ──────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'
info()  { echo -e "${GREEN}==>${NC} $*"; }
warn()  { echo -e "${YELLOW}WARN:${NC} $*"; }
error() { echo -e "${RED}ERROR:${NC} $*"; exit 1; }

# ── 1. Check ttyd ──────────────────────────────────────────────
if ! command -v ttyd &>/dev/null; then
  echo ""
  echo -e "${RED}ERROR: ttyd not found.${NC}"
  echo ""
  echo "  Install it with:"
  echo "    brew install ttyd          # macOS"
  echo "    sudo apt install ttyd      # Ubuntu/Debian"
  echo ""
  echo "  Then re-run: bash start-labspace.sh"
  exit 1
fi

# ── 2. Check kubectl ──────────────────────────────────────────
if ! command -v kubectl &>/dev/null; then
  echo ""
  echo -e "${RED}ERROR: kubectl not found.${NC}"
  echo ""
  echo "  kubectl is bundled with Docker Desktop."
  echo "  Make sure Kubernetes is enabled in Docker Desktop:"
  echo "    Settings > Kubernetes > Enable Kubernetes"
  echo ""
  echo "  Then re-run: bash start-labspace.sh"
  exit 1
fi

# ── 3. Check Kubernetes cluster is reachable ───────────────────
if ! kubectl cluster-info &>/dev/null 2>&1; then
  echo ""
  echo -e "${YELLOW}WARN: No Kubernetes cluster reachable.${NC}"
  echo ""
  echo "  Enable Kubernetes in Docker Desktop:"
  echo "    Settings > Kubernetes > Enable Kubernetes"
  echo ""
  echo "  Or create a cluster from the Kubernetes view in the Dashboard."
  echo ""
  echo "  Continuing anyway — you can enable it during the lab."
fi

# ── 4. Set CONTENT_PATH ───────────────────────────────────────
export CONTENT_PATH="${CONTENT_PATH:-$(pwd)}"
info "CONTENT_PATH set to: $CONTENT_PATH"

# ── 5. Validate compose.override.yaml exists ───────────────────
if [ ! -f "$COMPOSE_FILE" ]; then
  error "$COMPOSE_FILE not found. Are you running from the repo root?"
fi

# ── 6. Clear port ──────────────────────────────────────────────
info "Clearing port $TTYD_PORT..."
lsof -ti tcp:$TTYD_PORT | xargs kill -9 2>/dev/null || true
sleep 1

# ── 7. Start ttyd ──────────────────────────────────────────────
info "Starting terminal on port $TTYD_PORT..."
ttyd -p $TTYD_PORT --writable --max-clients 4 zsh &
TTYD_PID=$!
sleep 1

if ! lsof -ti tcp:$TTYD_PORT &>/dev/null; then
  error "ttyd failed to start on port $TTYD_PORT"
fi
info "ttyd PID: $TTYD_PID"

# ── 8. Start Labspace ─────────────────────────────────────────
if [ -f "compose.yaml" ]; then
  BASE_COMPOSE="compose.yaml"
elif [ -f "compose.yml" ]; then
  BASE_COMPOSE="compose.yml"
elif [ -f "docker-compose.yml" ]; then
  BASE_COMPOSE="docker-compose.yml"
else
  BASE_COMPOSE=""
fi

if [ -n "$BASE_COMPOSE" ]; then
  info "Starting Labspace (local compose: $BASE_COMPOSE)..."
  docker compose \
    -f "$BASE_COMPOSE" \
    -f "$COMPOSE_FILE" \
    up &
else
  info "Starting Labspace (OCI reference)..."
  docker compose \
    -f oci://dockersamples/labspace \
    -f "$COMPOSE_FILE" \
    up &
fi
COMPOSE_PID=$!

echo ""
echo "==========================================="
echo "  Labspace ready at http://localhost:3030"
echo "  Terminal  →  your Mac terminal (ttyd)"
echo "  kubectl, docker  →  native access"
echo "==========================================="
echo ""
echo "Press Ctrl+C to stop"

# ── 9. Cleanup on exit ─────────────────────────────────────────
cleanup() {
  echo ""
  info "Stopping..."
  kill $TTYD_PID 2>/dev/null || true
  if [ -n "$BASE_COMPOSE" ]; then
    docker compose \
      -f "$BASE_COMPOSE" \
      -f "$COMPOSE_FILE" \
      down 2>/dev/null || true
  else
    docker compose \
      -f oci://dockersamples/labspace \
      -f "$COMPOSE_FILE" \
      down 2>/dev/null || true
  fi
}
trap cleanup EXIT
wait $COMPOSE_PID
