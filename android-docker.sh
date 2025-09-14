#!/bin/bash

# Exit on error
set -euo pipefail

# Variables
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=${SCRIPT_DIR}

# Build docker image
IMAGE_NAME="ffmpeg-kit-android-build-container"
sudo docker build -t "${IMAGE_NAME}" -f "${SCRIPT_DIR}/Dockerfile" .

# Run docker container as current user and build project
sudo docker run -u $(id -u):$(id -g) --rm --cpus=$(($(nproc)-1 < 1 ? 1 : $(nproc)-1)) -v "${PROJECT_DIR}:/project" "${IMAGE_NAME}" bash -c "cd /project && ./android.sh${@+ $(printf ' %q' "$@")}"