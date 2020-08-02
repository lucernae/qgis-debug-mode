#!/usr/bin/env bash

# define your QGIS_REPO first

# You can define the location by exporting it in the shell before running this scripts, like this:
# export QGIS_REPO=qgis-location; sync-cache.sh
QGIS_REPO=${QGIS_REPO}
QGIS_IMAGE=${QGIS_IMAGE:-local/qgis-debug}

# Run temporary containers
docker run --rm -d --name temp-qgis ${QGIS_IMAGE} tail -f /dev/null
# Copy directory /QGIS/build into the current directory
docker cp temp-qgis:/QGIS/build ${QGIS_REPO}/build
# Copy /QGIS/.ccache_image_build into the current directory
docker cp temp-qgis:/QGIS/.ccache_image_build ${QGIS_REPO}/.ccache_image_build
# Copy lib headers from containers
docker cp temp-qgis:/usr/include ${QGIS_REPO}/build/include

docker stop temp-qgis