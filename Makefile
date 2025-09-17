
# Variables de entorno 
HTTP_PORT ?= 8080
TLS_PORT ?= 8443
MESSAGE ?= Servidor HTTP en Bash
DOMAIN ?= localhost
RELEASE ?= 1.0

# Carpetas
SRC_DIR := src
OUT_DIR := out
DIST_DIR := dist
TEST_DIR := tests

# Lista de scripts fuente
SOURCES := $(wildcard $(SRC_DIR)/*.sh)
OBJECTS := $(patsubst $(SRC_DIR)/%.sh,$(OUT_DIR)/%.sh,$(SOURCES))

# Regla patrón: copia solo los scripts modificados a out/
$(OUT_DIR)/%.sh: $(SRC_DIR)/%.sh
	@mkdir -p $(OUT_DIR)
	@cp $< $@
	@echo "Actualizado: $@"

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

# Generar certificados
generate-certs:
	@echo "Ejecutando script para generar certificado y clave privada..."
	@DOMAIN=$(DOMAIN) bash src/tls/generate_cert.sh

# Ejecutar servidor
run-http-server:
	@PORT=$(HTTP_PORT) MESSAGE="$(MESSAGE)" bash src/server/server.sh

# Ejecutar servidor TLS
run-tls-server:
	@echo "Ejecutando script para levantar el servidor TLS..."
	@DOMAIN=$(DOMAIN) PORT=$(TLS_PORT) bash src/tls/tls_server.sh -www

# Limpiar artefactos
clean:
	@echo "Limpiando archivos generados..."
	@rm -rf $(OUT_DIR) $(DIST_DIR)

# Target principal
all: evidence

# Realiza el chequeo de DNS (para sprint 2)
dns_check:
	@echo "Realizando chequeo de DNS..."
	@bash ./src/dns/dns_check.sh

# Para las evidencias se ejecuta un servidor en segundo plano, luego elimina el servidor
curl-http:
	@mkdir -p out/http
	@echo "Probando servidor HTTP con curl..."
	@curl -s http://localhost:$(PORT)/ > out/curl_root.txt
	@curl -s http://localhost:$(PORT)/bad > out/curl_404.txt
	@echo "Resultados generados en out/"
	

# Para las evidencias de una conexión con el servidor TLS, se tiene que levantar el servidor primero con make run-tls-server
curl-tls:
	@mkdir -p out/tls
	@echo "Probando conexión TLS con curl (ignorando validación)..."
	@curl -sk https://$(DOMAIN):$(TLS_PORT)/ > out/tls/curl_tls_root.txt
	@echo "Resultados generados en out/tls/curl_tls_root.txt"

# Para las evidencias del handshake del cliente con el servidor TLS
tls-handshake:
	@mkdir -p out/tls
	@echo "Capturando handshake con openssl s_client..."
	@openssl s_client -connect $(DOMAIN):$(TLS_PORT) -servername $(DOMAIN) < /dev/null > out/tls/openssl_handshake.txt 2>&1
	@echo "Resultados generados en out/tls/openssl_handshake.txt"

# Mostrar logs del servicio servidor
logs:
	@echo "Mostrando logs del servicio servidor..."
	@journalctl --user -u servidor -n 20 --no-pager

evidences: curl-http curl-tls tls-handshake

pack: $(DIST_DIR)/proyecto1-$(RELEASE).tar.gz

$(DIST_DIR)/proyecto1-$(RELEASE).tar.gz: $(SOURCES)
	@mkdir -p $(DIST_DIR)
	@tar -czf $@ $(SRC_DIR) docs
	@echo "Paquete generado: $@"