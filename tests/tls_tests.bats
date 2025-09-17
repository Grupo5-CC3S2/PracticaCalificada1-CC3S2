#!/usr/bin/env bats

setup() {
  DOMAIN="localhost"
  TLS_PORT=8443
}

@test "Servidor TLS acepta conexión y responde HTTP básico" {
  run curl -sk https://${DOMAIN}:${TLS_PORT}/
  [ "$status" -eq 0 ]
  [[ "$output" =~ "<HTML>" || "$output" =~ "200" ]]
}

@test "Servidor TLS rechaza conexión en puerto equivocado" {
  run curl -sk https://${DOMAIN}:9999/
  [ "$status" -ne 0 ]
}

@test "Handshake TLS negocia protocolo válido" {
  run bash -c "echo | openssl s_client -connect ${DOMAIN}:${TLS_PORT} -servername ${DOMAIN} 2>/dev/null | grep -E 'TLSv1\.[0-3]'"
  [ "$status" -eq 0 ]
}

@test "Handshake TLS incluye información de cipher suite" {
  run bash -c "echo | openssl s_client -connect ${DOMAIN}:${TLS_PORT} -servername ${DOMAIN} 2>/dev/null | grep 'Cipher'"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Cipher" ]]
}

@test "Servidor TLS mantiene conexión abierta para varias peticiones" {
  run bash -c "curl -sk --keepalive-time 2 https://${DOMAIN}:${TLS_PORT}/ && curl -sk --keepalive-time 2 https://${DOMAIN}:${TLS_PORT}/"
  [ "$status" -eq 0 ]
}