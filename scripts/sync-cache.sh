#!/usr/bin/env bash

docker run --rm -d --name temp-qgis local/qgis-debug tail -f /dev/null
docker cp temp-qgis:/QGIS/build ./
docker cp temp-qgis:/QGIS/.ccache_image_build ./.ccache_image_build
docker stop temp-qgis
docker rm temp-qgis