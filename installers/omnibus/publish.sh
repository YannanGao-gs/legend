#!/bin/bash

# NOTE: have to use -e for `echo` when using these colors to interpret the backslash escapes
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

source ./.env

DOCKER_IMAGE_NAME=finos/legend-omnibus
DOCKER_IMAGE_TAG=$LEGEND_OMNIBUS_IMAGE_VERSION

# Check if the image has already been published
ALREADY_PUBLISHED=true
docker pull finos/legend-omnibus:$DOCKER_IMAGE_VERSION >/dev/null 2>&1 || {
  ALREADY_PUBLISHED=false
}
if [[ $ALREADY_PUBLISHED = true ]]; then
  echo -e "${YELLOW}Image finos/legend-omnibus:$DOCKER_IMAGE_VERSION is already published. Aborting...${NC}"
  exit 0
fi

# Login to Docker Hub
#
# NOTE: Apparently, we cannot call `docker login ...` from `github-actions` pipeline
# as we will get the error: Cannot perform an interactive login from a non TTY device.
# so we will use `docker/login-action`, if we run this script manually, make sure we
# login beforehand.

# Build Docker image
bash ./build.sh
# Push Docker image
docker tag legend-omnibus:latest finos/legend-omnibus:$DOCKER_IMAGE_TAG
docker push --quiet finos/legend-omnibus:$DOCKER_IMAGE_TAG || {
  exit 1
}
docker tag legend-omnibus:latest finos/legend-omnibus:latest
docker push --quiet finos/legend-omnibus:latest || {
  exit 1
}

echo -e "\n"
echo -e "${GREEN}Successfully published image finos/legend-omnibus:$DOCKER_IMAGE_TAG to Docker Hub! ${NC}"
echo -e "\n"
