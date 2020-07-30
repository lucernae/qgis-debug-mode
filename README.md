# QGIS in debug mode

The aim of this project is to try to add remote debugging capabilities into an existing QGIS docker image.


Features:

- Compiled with CMAKE_BUILD_TYPE: DEBUG
- Include remote VNC connection
- Entrypoint script injection abilities. It is able to run a script before container online

# TLDR; Using the image

To build the image:

```bash
docker-compose build
```

However, the point of creating this project is to let Docker Hub build your image so you can just use it immediately.

To use the image:

Let's say we want to run debugging using GDB and view the interface (using VNC, not Xvfb).

Copy `resources/sample_debugger_scripts/gdb/docker-compose.override.yml` to `docker-compose.override.yml`. Location all relative to repo root directory.

```bash

```

## Customizing QGIS Build options

Customization can be built at runtime via environment variable `CMAKE_OPTIONS`