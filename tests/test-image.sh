#!/usr/bin/env bash
# Backwards-compatibility test suite for the neovim Docker image, built on
# Google's container-structure-test:
#   https://github.com/GoogleContainerTools/container-structure-test
#
# Builds the given Dockerfile (default: Dockerfile) and checks that the
# resulting image still provides everything the current production image
# provides: core tooling, the plugin/CoC install baked in at
# build time, the user/mount setup the rest of the repo (docker-compose.yaml,
# CLAUDE.md) assumes, and - with the real init.vim/coc-settings.json
# bind-mounted in the same way docker-compose.yaml does at runtime - that
# every plugin's keybindings actually load and work, not just that their
# plugin directories exist on disk.
#
# Pass a different Dockerfile to check a variant for parity with the
# known-good Dockerfile before pointing docker-compose.yaml at it.
#
# Usage: tests/test-image.sh [Dockerfile]

set -uo pipefail
cd "$(dirname "$0")/.."

DOCKERFILE="${1:-Dockerfile}"
IMAGE_TAG="neovim-test:$$"
LOCAL_UNAME="$(whoami)"
CST_BIN="tests/.bin/container-structure-test"
CST_URL="https://github.com/GoogleContainerTools/container-structure-test/releases/latest/download/container-structure-test-linux-amd64"

if [[ ! -f "$DOCKERFILE" ]]; then
    echo "No such Dockerfile: $DOCKERFILE" >&2
    exit 2
fi

if [[ ! -x "$CST_BIN" ]]; then
    echo "Fetching container-structure-test..."
    mkdir -p tests/.bin
    if ! curl -fsSL -o "$CST_BIN" "$CST_URL"; then
        echo "Failed to download container-structure-test from $CST_URL" >&2
        rm -f "$CST_BIN"
        exit 2
    fi
    chmod +x "$CST_BIN"
fi

GENERATED="$(mktemp --suffix=.yaml)"
FUNCTIONAL="$(mktemp --suffix=.yaml)"
cleanup() {
    docker rmi -f "$IMAGE_TAG" >/dev/null 2>&1 || true
    rm -f "$GENERATED" "$FUNCTIONAL"
}
trap cleanup EXIT

echo "Building $DOCKERFILE as $IMAGE_TAG ..."
BUILD_LOG="$(mktemp)"
if ! docker build -q -t "$IMAGE_TAG" \
        --build-arg UID="$(id -u)" \
        --build-arg GID="$(id -g)" \
        --build-arg LOCAL_UNAME="$LOCAL_UNAME" \
        -f "$DOCKERFILE" . >"$BUILD_LOG" 2>&1; then
    echo "FAIL: image build"
    cat "$BUILD_LOG"
    rm -f "$BUILD_LOG"
    exit 1
fi
rm -f "$BUILD_LOG"

./tests/generate-cst-config.sh "$DOCKERFILE" "$LOCAL_UNAME" > "$GENERATED"
./tests/generate-functional-config.sh > "$FUNCTIONAL"

"$CST_BIN" test --image "$IMAGE_TAG" \
    --config tests/cst/base.yaml \
    --config "$GENERATED" \
    --config "$FUNCTIONAL"
