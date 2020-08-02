#!/usr/bin/env

# GDB Server must run inside the container as Host
# Then debugger client must connect to it

apt -y update; apt -y install gdbserver

# Run as Docker Command:
# Start QGIS using gdbserver
# gdbserver 0.0.0.0:34567 /QGIS/QGIS/build/output/qgis

# Attach to current running gdbserver (useful for unittesting)
# gdbserver 0.0.0.0:34567 `pidof -s <program>`