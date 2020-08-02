# QGIS in debug mode

The aim of this project is to try to add remote debugging capabilities into an existing QGIS docker image.


Features:

- Compiled with CMAKE_BUILD_TYPE: DEBUG
- Include remote VNC connection
- SSH + Rsync Server available
- Entrypoint script injection abilities. It is able to run a script before container online

# TLDR; Using the image

To build the image:

```bash
docker-compose build
```

However, the point of creating this project is to let Docker Hub build your image so you can just use it immediately.
So, I recommend that you clone the repo and built it yourself using docker hub, then pull it.

To use the image:

Copy `.example.env` as `.env` in the root project folder.
This will contain environment variable override.

Let's say we want to run debugging using GDB and view the interface (using VNC, not Xvfb).

Copy `resources/sample_debugger_scripts/gdb/docker-compose.override.yml` to `docker-compose.override.yml`. All location are relative to repo's root directory.

To use VNC Display, change into this:

```yaml
version: '3'
services: 
    qgis:
        command: /bin/bash -c "while [ 'TRUE' ]; do gdbserver 0.0.0.0:34567 /QGIS/build/output/bin/qgis; done"
        environment: 
            # VNC Display uses DISPLAY :98
            DISPLAY: ":98"
        ports: 
            - "34567:34567"
```

Short explanation:
- We are running gdbserver on the container and expose it to port 34567, then run prebuilt QGIS binary located in `/QGIS/build/output/bin/qgis`
- We are using Tightvncserver display in DISPLAY :98
- We are exposing port 34567 to host, so local gdb client can connect to it

Run the services:

```yaml
docker-compose up -d
```

VNC port are exposed to port `5998` (which is 5900 + Display number). These rules are declared in the main `docker-compose.yml` file. You can connect to it using VNC Viewer application with default credentials:

    host: localhost:5998
    user: root
    pass: userpass

With above gdbserver command, QGIS will run when gdb has connected.
How you connect to it depends on the IDE you choose, but to quickly check it, run gdb and perform internal command:

```bash
gdb
gdb> target remote localhost:34567
gdb> info sources
```

# Customization

To do some various things and modifications, see example below.

## Change environment variable

Docker will use environment variable defined in `.env` file.
Overriding those will change the value in docker-compose.yml file

## Use different CMAKE_OPTIONS

Changing cmake behaviour can be done via docker build variable `CMAKE_OPTIONS`.

Using docker build:

```bash
docker build --build-arg CMAKE_OPTIONS=<super long CMAKE Flags> -t local/qgis-debug .
```

Using docker-compose build:

```bash
docker-compose --build-arg CMAKE_OPTIONS=<super long CMAKE flags> build
```

Using Docker Hub, just set CMAKE_OPTIONS in the autobuild settings for the build args.


## Extracting build cache

Inside the containers, the project directory is in `/QGIS`. The cmake build directory is in `/QGIS/build`. The CCACHE_DIR is in `/QGIS/.ccache_image_build`. Simply use docker cp to extract this out. You can look at example in [sync-cache.sh](scripts/sync-cache.sh)

After it was extracted, you can volume mount those directory to make sure any changes for the build are persisted. This is very useful if you do debug + edit workflow.
Since recompiling means you need to change the source code, don't forget to mount the source code from your local QGIS repo:

Some sample `docker-compose.override.yml` with this intention.

```yaml
version: '3'
services: 
    qgis:
        command: /bin/bash -c "while [ 'TRUE' ]; do gdbserver 0.0.0.0:34567 /QGIS/build/output/bin/qgis; done"
        environment: 
            DISPLAY: ":98"
        ports: 
            - "34567:34567"
        volumes: 
            - ${QGIS_REPO}/build:/QGIS/build
            - ${QGIS_REPO}/.ccache_image_build:/QGIS/.ccache_image_build
            - ${QGIS_REPO}/src:/QGIS/src
```

Add new environment variable in `.env` file in this project directory to let docker-compose know where `QGIS_REPO` is:

```.env
QGIS_REPO=/home/<user>/apps/QGIS/qgis
```

In addition to that, it is sometimes useful to extract the headers file.
The header files are located inside containers in dir `/usr/include`. You can copy this file along in your QGIS project repo.

## Rebuilding using docker

If you use other CMAKE flags, then you need to set it inside the docker-compose override recipe:

```yaml
version: '3'
services:
    qgis:
        # I will only put relevant key in environment key
        environment:
            CMAKE_OPTIONS: "<super long CMAKE flags>"

```

You need to apply the cmake conf:

```bash
docker-compose exec qgis /build-debug.sh
```

For subsequent rebuilding, execute this command:

```bash
docker-compose exec qgis ninja install
```

You can hook above command to your IDE to make it autorebuild on demand.

## Hooking extra preparation scripts

You might want to hook extra scripts before your debug server/setup ready.
The image is equipped with a `docker-entrypoint.sh` script that will execute extra `sh` scripts in the directory inside containers: `/docker-entrypoint-scripts.d`.

So, if you want to include the scripts, customize your docker-compose override recipe:

```yaml
version: '3'
services:
    qgis:
        # I will only put relevant key in environment key
        volumes:
            # Mounting a directory
            - "${PWD}/your-scripts-dir:/docker-entrypoint-scripts.d
            # Mounting a file
            # - "${PWD}/your-script.sh:/docker-entrypoint-scripts.d/your-script.sh
```

These scripts are going to be executed when you first run `docker-compose up -d` in a fresh stack.

Since there is a possible case where you want to install extra python modules/app, you can do that by mounting the requirements.txt file. Any file with name suffix `requirements.txt` will be inspected.

```yaml
version: '3'
services:
    qgis:
        # I will only put relevant key in environment key
        volumes:
            # Mounting a python requirements.txt
            - "${PWD}/my-dependencies.requirements.txt:/docker-entrypoint-scripts.my-dependencies.requirements.txt
```

## IDE Integrations

I mainly uses VSCode and PyCharm.

### VSCode

To Debug C++ code, you can use VSCode

#### Requirements

- VSCode
- Official C++ VSCode extension 
- gdb

In the `resources/sample_debugger_scripts/gdb` there are sample scripts usable by VSCode.

The file `resources/sample_debugger_scripts/gdb/.vscode/launch.json` is for the `.vscode/launch.json` file. It is used to launch the debugger when user press F5 in vscode.
The file `resources/sample_debugger_scripts/gdb/.vscode/tasks.json` is for the `.vscode/tasks.json` file. It is used to run build task.

Link the volume mount used by docker-compose in this repository with the same location in your QGIS repo openned by vscode. If you use `QGIS_REPO` environment variable, coupled with this setup: [Extracting build cache](#extracting-build-cache), then that means the `.ccache_image_build`, `build`, and `src` dir are linked with the location in your QGIS repo.

In the `launch.json` file there is an options to specify file mapping. You can specify source code map (from host to container), so that when gdbserver refer to a source code in the container, VSCode can understand that it refer the same file in your host directory.
The highlighted settings are here:

```json
{
          "sourceFileMap": {
            // left are container filesystem: right are host filesystem
            "/QGIS": "${workspaceRoot}",
            // If you extracted the header files, you can also map it here
            // "/usr/lib/include": "${workspaceRoot}/build/include"
          },
```

In addition to that, since you will mostly debug Qt Framework, you can include gdb command definition in `resources/sample_debugger_scripts/gdb/.gdbinit` into your `~/.gdbinit`.
This will allow you to print of Qt5 String in VSCode from the gdb terminal.
From the debug console, execute:

```gdb
-exec printqs5static <qstring variable>
```

### PyCharm

You can debug Python code (for plugins) using PyCharm Pro edition.

#### Requirements

- PyCharm Professional Edition

Debugging using PyCharm Debug Server is a little bit different in architecture.
Using GDB, you instantiate debug server inside the **container**.
But, using PyCharm Debug Server, the pydevd debug server is instantiated in your **host** machine, the place where you run PyCharm itself.
That means your containers need to be able to access your host machine to access debug server.

If you add Debug Server configuration in PyCharm there are some instructions PyCharm will provide for you, it can be broken down in two step

1. Install pydevd-pycharm package with specific version inside your container

Add the following extra keys to your `docker-compose.override.yml`

```yaml
version: '3'
services:
    qgis:
        environment:
            PYCHARM_VERSION: "your-pycharm-version"
        volumes:
            - ${PWD}/resources/sample_debugger_scripts/pydevd/remote_pydevd_client.sh:/docker-entrypoint-scripts.d/remote_pydevd_client.sh
        ports:
            # This will be your pydevd ports
            - "34568:34568"
```

2. Copy paste the stack trace code into your plugin's `__init__.py` script.

```python3
import pydevd
pydevd_pycharm.settrace('<host>', port=34568, stdoutToServer=True, stderrToServer=True)
```

Replace '<host>'  with the ipaddress of your network bridge. You can check by using `ifconfig` and see your WiFi/Ethernet or Docker Bridge interface