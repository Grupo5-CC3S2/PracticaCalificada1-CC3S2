#!/usr/bin/env bash
set -euo pipefail

# Si no se define DOMAIN, se produce un error
: "${DOMAIN:?Debe definir DOMAIN (ej. export DOMAIN=localhost)}"

CERT_DIR="out/certs"
SIM_ROOT="out/sim/root"
SIM_AUDITOR="out/sim/auditor"

KEY_FILE="${CERT_DIR}/${DOMAIN}.key"
CRT_FILE="${CERT_DIR}/${DOMAIN}.crt"

ROLES=("root" "auditor")

# Acción del usuario root
rol_root() {
    echo "[root] Generando clave privada y certificado público..."
    mkdir -p "$CERT_DIR" "$SIM_ROOT"

    # Se genera el certificado público y la clave privada para la conexión TLS
    openssl req -x509 -nodes -newkey rsa:2048 \
      -keyout "$KEY_FILE" -out "$CRT_FILE" -days 365 \
      -subj "/CN=${DOMAIN}" > /dev/null 2>&1

    # Permisos
    chmod 600 "$KEY_FILE"
    chmod 644 "$CRT_FILE"

    cp "$KEY_FILE" "$CRT_FILE" "$SIM_ROOT/"

    echo "[root] Se generaró correctamente la clave y certificado"
    echo "[root] Se definieron correctamente los permisos para los archivos (key=600, crt=644)"
}

# Acción del usuario auditor
rol_auditor() {
    echo "[auditor] Revisando el certificado público..."
    mkdir -p "$SIM_AUDITOR"

    cp "$CRT_FILE" "$SIM_AUDITOR/"

    echo "[auditor] Se pudo tener acceso a el certificado público"
}

for role in "${ROLES[@]}"; do
    case "$role" in
        "root") rol_root ;;
        "auditor") rol_auditor ;;
    esac
done
