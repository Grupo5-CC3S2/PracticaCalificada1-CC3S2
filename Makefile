# Variables de entorno 
PORT ?= 8080
MESSAGE ?= Servidor HTTP en Bash
HOSTNAME ?= localhost

# Carpetas
SRC_DIR := src
OUT_DIR := out
DIST_DIR := dist
TEST_DIR := tests

# Mostrar ayuda
help:
	@echo "Uso: make [target]"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  tools   - Verificar herramientas necesarias (nc, curl, dig, openssl, bats)"
	@echo "  build   - Preparar artefactos (ej: empaquetar)"
	@echo "  test    - Ejecutar pruebas con bats"
	@echo "  run     - Levantar servidor web en puerto $(PORT)"
	@echo "  clean   - Limpiar artefactos generados"

# Verificar dependencias
tools:
	@echo "Verificando herramientas..."
	@for tool in nc curl dig openssl bats; do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			echo "Falta instalar $$tool"; \
			exit 1; \
		else \
			echo "$$tool disponible"; \
		fi; \
	done

# Construcción
build:
	@echo "Construyendo proyecto..."
	@mkdir -p $(DIST_DIR)
	@tar -czf $(DIST_DIR)/servidor.tar.gz $(SRC_DIR) docs

# Pruebas
test:
	@echo "Ejecutando pruebas..."
	@if [ -d $(TEST_DIR) ]; then \
		bats $(TEST_DIR); \
	else \
		echo "No hay carpeta de tests/"; \
	fi

# Ejecutar servidor
run-server:
	PORT=$(PORT) MESSAGE="$(MESSAGE)" bash src/server/server.sh

# Limpiar artefactos
clean:
	@echo "Limpiando archivos generados..."
	@rm -rf $(OUT_DIR) $(DIST_DIR)

# Target principal
all: evidence

# Realiza el chequeo de DNS (para sprint 2)
dns_check:
	@echo "Realizando chequeo de DNS..."
	@./src/dns/dns_check.sh

# Genera todas las evidencias
evidence:
	@echo "Generando evidencias de HTTP y DNS..."
	@./run_evidence.sh

# Para las evidencias se ejecuta un servidor en segundo plano, luego elimina el servidor
evidences-curl:
	@mkdir -p out
	@curl -s http://localhost:$(PORT)/ > out/curl_root.txt
	@curl -s http://localhost:$(PORT)/bad > out/curl_404.txt
	@cat out/curl_root.txt
	@cat out/curl_404.txt

# evidencias completas, asume que el servidor se esta ejecutando para curl
evidences: evidences-curl

