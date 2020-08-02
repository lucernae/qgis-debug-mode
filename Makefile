

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

qgis-rebuild:
	docker-compose exec qgis /bin/bash -c "/build-debug.sh; ninja install"

shell:
	docker-compose exec qgis bash