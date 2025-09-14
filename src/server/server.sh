#!/bin/bash

set -euo pipefail

# Pasamos las variables de entorno
PORT="${PORT:-8080}"
MESSAGE="${MESSAGE:-Hello World}"

# Creamos el directorio en caso no exista
mkdir -p out/logs

# Funcion para manejo de limpieza
cleanup() {
  if [ -n "${pipe:-}" ] && [ -e "${pipe:-}" ]; then
    rm -f "$pipe"
  fi
}

trap cleanup EXIT INT TERM

# Bucle del servidor para no terminar como una sola peticion
while true; do
  pipe=$(mktemp -u /tmp/server_pipe.XXXXXX)
  mkfifo "$pipe" || { echo "Failed to create FIFO" >&2; exit 1; }
  trap "rm -f '$pipe'; exit" INT TERM EXIT

  nc -l -p "$PORT" <"$pipe" | (
    # lee la linea de solcitud
    read -r request_line || exit 1

    # Omitir el resto de encabezados hasta que quede linea en blanco
    while read -r line; do
      line="${line%%$'\r'}"
      [ -z "$line" ] && break
    done

    # Extrae la ruta e ignora los parametros de consulta
    path="$(echo "$request_line" | awk '{print $2}' | cut -d'?' -f1)"

    #registra la solicitud
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $request_line" >> out/logs/access.log

    if [ "$path" = "/" ]; then
      status="200 OK"
      body="200 OK: $MESSAGE"
    else
      status="404 Not Found"
      body="Error 404: Resource not found"
    fi

    content_length="${#body}"

    # Muestra el resultado de la consulta
    printf "HTTP/1.1 %s\r\n" "$status"
    printf "Content-Type: text/plain\r\n"
    printf "Content-Length: %d\r\n" "$content_length"
    printf "Connection: close\r\n"
    printf "\r\n"
    printf "%s" "$body"

    # registra el estado de la respuesta en out
    echo "[$timestamp] Response: $status" >> out/logs/access.log
  ) >"$pipe"

  # limpia el pipe despues de procesar la solicitud
  rm -f "$pipe"
  trap cleanup EXIT INT TERM
done