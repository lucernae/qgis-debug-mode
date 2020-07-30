#!/usr/bin/env bash

echo "Running CMAKE"

# This script is executed in the cmake build directory: /QGIS/build
read -r -d '' _CMAKE_OPTIONS << EOF
  -GNinja \
  -DUSE_CCACHE=OFF \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX=/QGIS/build/output \
  -DWITH_DESKTOP=ON \
  -DWITH_SERVER=ON \
  -DWITH_3D=ON \
  -DWITH_BINDINGS=ON \
  -DWITH_CUSTOM_WIDGETS=ON \
  -DBINDINGS_GLOBAL_INSTALL=ON \
  -DWITH_STAGED_PLUGINS=ON \
  -DWITH_GRASS=ON \
  -DSUPPRESS_QT_WARNINGS=ON \
  -DDISABLE_DEPRECATED=ON \
  -DENABLE_TESTS=OFF \
  -DWITH_QSPATIALITE=ON \
  -DWITH_APIDOC=OFF \
  -DWITH_ASTYLE=OFF \
  -DQT5_3DEXTRA_LIBRARY="/usr/lib/x86_64-linux-gnu/libQt53DExtras.so" \
  -DQT5_3DEXTRA_INCLUDE_DIR="/QGIS/external/qt3dextra-headers" \
  -DCMAKE_PREFIX_PATH="/QGIS/external/qt3dextra-headers/cmake"
EOF

CMAKE_OPTIONS=${CMAKE_OPTIONS:-$_CMAKE_OPTIONS}

echo "Full cmake command:"

echo "cmake \
  ${CMAKE_OPTIONS} \
 .."

cmake \
  ${CMAKE_OPTIONS} \
 ..