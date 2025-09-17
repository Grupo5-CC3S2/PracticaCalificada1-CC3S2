#!/usr/bin/env bash

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

  nc -l -p "$PORT" <"$pipe" | (
    # lee la linea de solicitud
    read -r request_line || exit 1

    # Omitir el resto de encabezados hasta que quede linea en blanco
    while read -r line; do
      line="${line%%$'\r'}"
      [ -z "$line" ] && break
    done

    # Extrae metodo, ruta e ignora los parametros de consulta
    method="$(echo "$request_line" | awk '{print $1}')"
    path="$(echo "$request_line" | awk '{print $2}' | cut -d'?' -f1)"
    http_version="$(echo "$request_line" | awk '{print $3}')"

    # Registra la solicitud
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $request_line" >> out/logs/access.log

    # Validación del método HTTP
    case "$method" in
      "GET"|"HEAD")
        # Métodos soportados
        ;;
      "")
        status="400 Bad Request"
        body="Error 400: Bad Request - Missing HTTP method"
        ;;
      *)
        status="405 Method Not Allowed"
        body="Error 405: Method Not Allowed - Supported methods: GET, HEAD"
        ;;
    esac

    # Si no hay error de método, procesar la ruta
    if [ -z "${status:-}" ]; then
      case "$path" in
        "/")
          status="200 OK"
          body="200 OK: $MESSAGE"
          ;;
        "/status")
          status="200 OK"
          body="Server Status: Running on port $PORT"
          ;;
        "/health")
          status="200 OK"
          body="Health: OK"
          ;;
        *)
          status="404 Not Found"
          body="Error 404: Resource not found"
          ;;
      esac
    fi
    
    response_headers=""
    response_headers+="HTTP/1.1 $status"$'\r\n'
    response_headers+="Content-Type: text/plain"$'\r\n'
    response_headers+="Server: BashHTTP/1.0"$'\r\n'
    response_headers+="Date: $(date -u '+%a, %d %b %Y %H:%M:%S GMT')"$'\r\n'
    response_headers+="Connection: close"$'\r\n'
    response_headers+=$'\r\n'


    # Enviar respuesta según el método
    if [ "$method" = "HEAD" ]; then
      # Para HEAD solo enviamos headers, sin body
      printf "%s" "$response_headers"
    else
      # Para GET enviamos headers + body
      printf "%s" "$response_headers"
      printf "%s" "$body"
    fi

    # Registra el estado de la respuesta
    echo "[$timestamp] Response: $status (Method: $method, Path: $path)"
  ) >"$pipe"

  # Limpia el pipe despues de procesar la solicitud
  rm -f "$pipe"
done