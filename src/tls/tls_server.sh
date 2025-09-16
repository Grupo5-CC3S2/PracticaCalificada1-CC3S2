#!/usr/bin/env bash
set -euo pipefail

: "${DOMAIN:?Debe definir DOMAIN (ej. export DOMAIN=localhost)}"
: "${PORT:?Debe definir PORT (ej. export PORT=8443)}"

trap "echo -e '\nApagando servidor TLS...'" SIGINT SIGTERM

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
CERT_DIR="${ROOT_DIR}/out/certs"
KEY_FILE="${CERT_DIR}/${DOMAIN}.key"
CRT_FILE="${CERT_DIR}/${DOMAIN}.crt"

if [[ ! -s "$CRT_FILE" || ! -s "$KEY_FILE" ]]; then
  echo "[Error] Certificado o clave vacíos/no válidos."
  echo "Ejecuta generate_certs.sh o make generate-certs para regenerarlos"
  exit 1
fi

if ! openssl x509 -in "$CRT_FILE" -noout >/dev/null 2>&1; then
  echo "[Error] El archivo de certificado $CRT_FILE no es válido."
  exit 1
fi

if ! openssl rsa -in "$KEY_FILE" -check -noout >/dev/null 2>&1; then
  echo "[Error] El archivo de clave privada $KEY_FILE no es válido."
  exit 1
fi

echo "Iniciando servidor TLS en puerto $PORT..."
openssl s_server -cert "$CRT_FILE" -key "$KEY_FILE" -accept "$PORT" -www