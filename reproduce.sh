#!/usr/bin/env bash
set -e

# ESC-23344 Reproduction Script
# Reproduces: Intermittent App Platform Build Failures During Snapshot Stage
#
# Prerequisites:
# - Docker running
# - kaniko-builder image built locally (see apps-images/dev/build)
#   OR use digitaloceanapps/kaniko:v1.19.3 directly

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KANIKO_IMAGE="${KANIKO_IMAGE:-local/kaniko-builder:dev}"

echo "=== ESC-23344 Reproduction ==="
echo "Using kaniko image: ${KANIKO_IMAGE}"
echo ""

# Check if kaniko image exists
if ! docker image inspect "$KANIKO_IMAGE" &>/dev/null; then
    echo "ERROR: Image '$KANIKO_IMAGE' not found."
    echo ""
    echo "Build it first:"
    echo "  cd ../apps-images && dev/install-tools && REGISTRY=local dev/build --skip-prereqs"
    echo ""
    echo "Or set KANIKO_IMAGE to an available image:"
    echo "  KANIKO_IMAGE=digitaloceanapps/kaniko-builder:v0.94.0 ./reproduce.sh"
    exit 1
fi

echo "--- Step 1: Running first build (primes the cache) ---"
docker run --rm \
    -v "${SCRIPT_DIR}":/.app_platform_workspace \
    -e SKIP_RETRIEVE=1 \
    -e APP_PLATFORM_COMPONENT_TYPE=service \
    -e APP_IMAGE_URL=test/esc-23344:latest \
    -e DOCKERFILE_PATH=Dockerfile \
    -e KANIKO_USE_NEW_RUN=1 \
    -e KANIKO_VERBOSITY=debug \
    -e APP_CACHE_DIR=/tmp/kaniko-cache \
    -e SKIP_EXPORT=1 \
    "$KANIKO_IMAGE"

echo ""
echo "--- Step 2: Running second build (uses cached layers - may trigger race condition) ---"
docker run --rm \
    -v "${SCRIPT_DIR}":/.app_platform_workspace \
    -e SKIP_RETRIEVE=1 \
    -e APP_PLATFORM_COMPONENT_TYPE=service \
    -e APP_IMAGE_URL=test/esc-23344:latest \
    -e DOCKERFILE_PATH=Dockerfile \
    -e KANIKO_USE_NEW_RUN=1 \
    -e KANIKO_VERBOSITY=debug \
    -e APP_CACHE_DIR=/tmp/kaniko-cache \
    -e SKIP_EXPORT=1 \
    "$KANIKO_IMAGE"

echo ""
echo "=== If the above succeeded, the race condition didn't trigger this time ==="
echo "=== Run again or use reproduce-interactive.sh for manual investigation ==="
