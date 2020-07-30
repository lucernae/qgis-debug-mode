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

# SSH support
# Useful for debugging via SSH connections
RUN apt -y update; apt -y install openssh-server
RUN mkdir /var/run/sshd
ARG SSH_PASSWORD=docker
RUN echo 'root:${SSH_PASSWORD}' | chpasswd
# Allow login as root useful for development
# Comment out PermitRootLogin setting, whatever it is
RUN sed -i 's/^PermitRootLogin */#PermitRootLogin /' /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# VNC support
# Useful if you want to see QGIS GUI directly when the automated unittest is running
RUN apt -y update; apt -y install tightvncserver xterm

RUN mkdir -p /root/.vnc
ADD resources/xstartup /root/.vnc/xstartup

# Note: XVfb support has already been in the official image repo
# We don't need to configure anything extra

# Entrypoint scripts
# Useful to provide extra hooks before the container is up
ADD scripts/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

# Doesn't do anything by default
CMD []
