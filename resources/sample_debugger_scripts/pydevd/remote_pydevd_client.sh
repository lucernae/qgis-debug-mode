#!/usr/bin/env bash

# For PyCharm debug server, the workflow is:
# - Debug server run on your host
# - Containers connect to debug server by accessing host port

# declare PYCHARM_VERSION via .env file
pip3 install pydevd-pycharm~=${PYCHARM_VERSION}