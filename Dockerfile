ARG QGIS_VERSION=latest

FROM qgis/qgis:${QGIS_VERSION}

# QGIS Source code is in /QGIS directory

# Rebuild with debug mode

WORKDIR /QGIS/build

ARG SKIP_BUILD=""
ARG BUILD_TIMEOUT=360000
ARG CMAKE_OPTIONS=""

ADD scripts/build-debug.sh /build-debug.sh

RUN /build-debug.sh \
 && echo "Timeout: ${BUILD_TIMEOUT}s" \
 && SUCCESS=OK \
 && timeout ${BUILD_TIMEOUT}s ninja install || SUCCESS=TIMEOUT \
 && echo "$SUCCESS" > /QGIS/build_exit_value

RUN apt -y update; apt -y install tightvncserver xterm

RUN mkdir -p /root/.vnc
ADD resources/xstartup /root/.vnc/xstartup

ADD scripts/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD []