#!/bin/bash

# NOTE: have to use -e for `echo` when using these colors to interpret the backslash escapes
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

source ./.env

DOCKER_IMAGE_NAME=finos/legend-omnibus
DOCKER_IMAGE_TAG=$LEGEND_OMNIBUS_IMAGE_VERSION

# ------------------------------- Check -------------------------------

# Check if the image has already been published
ALREADY_PUBLISHED=true
docker pull finos/legend-omnibus:$DOCKER_IMAGE_TAG-slim >/dev/null 2>&1 || {
  ALREADY_PUBLISHED=false
}
if [[ $ALREADY_PUBLISHED = true ]]; then
  echo -e "${YELLOW}Image finos/legend-omnibus:$DOCKER_IMAGE_TAG-slim is already published. Aborting...${NC}"
  exit 0
fi

# ------------------------------- Test -------------------------------

echo "Running test(s)..."
bash ./variants/slim/build.sh
bash ./variants/slim/test.sh

# ----------------------------- Publish ------------------------------

docker tag legend-omnibus:latest-slim finos/legend-omnibus:$DOCKER_IMAGE_TAG-slim
docker push --quiet finos/legend-omnibus:$DOCKER_IMAGE_TAG-slim || {
  exit 1
}
docker tag legend-omnibus:latest-slim finos/legend-omnibus:latest-slim
docker push --quiet finos/legend-omnibus:latest-slim || {
  exit 1
}

# ------------------------- Summary -------------------------

echo -e "\n"
echo -e "${GREEN}Successfully published images to Docker Hub! ${NC}"
echo -e "\n"
