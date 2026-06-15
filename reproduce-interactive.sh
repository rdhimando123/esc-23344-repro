#!/usr/bin/env bash
set -e

# ESC-23344 Interactive Reproduction
# Drops you into the kaniko-builder container with bash for manual debugging

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KANIKO_IMAGE="${KANIKO_IMAGE:-local/kaniko-builder:dev}"

echo "=== ESC-23344 Interactive Reproduction ==="
echo "Using kaniko image: ${KANIKO_IMAGE}"
echo ""
echo "Once inside the container, run:"
echo ""
echo "  export SKIP_RETRIEVE=1"
echo "  export APP_PLATFORM_COMPONENT_TYPE=service"
echo "  export APP_IMAGE_URL=test/esc-23344:latest"
echo "  export DOCKERFILE_PATH=Dockerfile"
echo "  export KANIKO_USE_NEW_RUN=1"
echo "  export KANIKO_VERBOSITY=debug"
echo "  export APP_CACHE_DIR=/tmp/kaniko-cache"
echo "  export SKIP_EXPORT=1"
echo ""
echo "  /.app_platform/build.sh    # First run - primes cache"
echo "  /.app_platform/build.sh    # Second run - triggers race condition"
echo ""
echo "Dropping into bash..."
echo ""

docker run -it --rm \
    -v "${SCRIPT_DIR}":/.app_platform_workspace \
    --entrypoint bash \
    "$KANIKO_IMAGE"
