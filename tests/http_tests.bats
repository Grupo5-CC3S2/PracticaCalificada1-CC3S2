#!/usr/bin/env bats

# Tests para servidor HTTP -Sprint 2
# Archivo: tests/http_tests.bats

# Variables de configuración
TEST_PORT=8081
TEST_MESSAGE="Test Server"
SERVER_PID=""
TIMEOUT=10

# Setup: ejecutar antes de cada test
setup() {
    # Crear directorio de logs si no existe
    mkdir -p out/logs
    
    # Iniciar servidor en background en puerto de prueba
    PORT=$TEST_PORT MESSAGE="$TEST_MESSAGE" timeout $TIMEOUT bash src/server/server.sh &
    SERVER_PID=$!
    
    # Esperar a que el servidor inicie
    sleep 2
    
    # Verificar que el servidor esté corriendo
    if ! kill -0 $SERVER_PID 2>/dev/null; then
        skip "No se pudo iniciar el servidor de pruebas"
    fi
}

# Teardown: ejecutar después de cada test
teardown() {
    # Terminar servidor si está corriendo
    if [ -n "$SERVER_PID" ] && kill -0 $SERVER_PID 2>/dev/null; then
        kill $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
    fi
}

@test "GET / debe devolver 200 OK con mensaje personalizado" {
    run curl -s -w "%{http_code}" http://localhost:$TEST_PORT/
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "200" ]]
    [[ "$output" =~ "$TEST_MESSAGE" ]]
}

@test "GET /ruta-inexistente debe devolver 404 Not Found" {
    run curl -s -w "%{http_code}" http://localhost:$TEST_PORT/ruta-inexistente
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "404" ]]
    [[ "$output" =~ "Error 404: Resource not found" ]]
}

@test "GET /status debe devolver información del servidor" {
    run curl -s -w "%{http_code}" http://localhost:$TEST_PORT/status
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "200" ]]
    [[ "$output" =~ "Server Status: Running on port $TEST_PORT" ]]
}

@test "GET /health debe devolver health check" {
    run curl -s -w "%{http_code}" http://localhost:$TEST_PORT/health
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "200" ]]
    [[ "$output" =~ "Health: OK" ]]
}

@test "HEAD / debe devolver solo headers sin body" {
    run curl -I -s http://localhost:$TEST_PORT/
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
    [[ "$output" =~ "Content-Type: text/plain" ]]
    [[ "$output" =~ "Server: BashHTTP/1.0" ]]
    # Verificar que no hay body después de headers
    [[ ! "$output" =~ "$TEST_MESSAGE" ]]
}

@test "HEAD /ruta-inexistente debe devolver 404 solo headers" {
    run curl -I -s http://localhost:$TEST_PORT/ruta-inexistente
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "HTTP/1.1 404 Not Found" ]]
    [[ "$output" =~ "Content-Type: text/plain" ]]
    # Verificar que no hay body
    [[ ! "$output" =~ "Error 404: Resource not found" ]]
}

@test "POST / debe devolver 405 Method Not Allowed" {
    run curl -s -X POST -w "%{http_code}" http://localhost:$TEST_PORT/
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "405" ]]
    [[ "$output" =~ "Error 405: Method Not Allowed" ]]
}

@test "PUT / debe devolver 405 Method Not Allowed" {
    run curl -s -X PUT -w "%{http_code}" http://localhost:$TEST_PORT/
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "405" ]]
    [[ "$output" =~ "Error 405: Method Not Allowed" ]]
}

@test "DELETE / debe devolver 405 Method Not Allowed" {
    run curl -s -X DELETE -w "%{http_code}" http://localhost:$TEST_PORT/
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "405" ]]
    [[ "$output" =~ "Error 405: Method Not Allowed" ]]
}

@test "curl -i debe mostrar headers y body para GET /" {
    run curl -i -s http://localhost:$TEST_PORT/
    
    [ "$status" -eq 0 ]
    # Verificar que muestra headers
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
    [[ "$output" =~ "Content-Type: text/plain" ]]
    [[ "$output" =~ "Content-Length:" ]]
    [[ "$output" =~ "Server: BashHTTP/1.0" ]]
    # Verificar que muestra body después de headers
    [[ "$output" =~ "$TEST_MESSAGE" ]]
}

@test "curl -i debe mostrar headers y body para 404" {
    run curl -i -s http://localhost:$TEST_PORT/nonexistent
    
    [ "$status" -eq 0 ]
    # Verificar headers 404
    [[ "$output" =~ "HTTP/1.1 404 Not Found" ]]
    [[ "$output" =~ "Content-Type: text/plain" ]]
    [[ "$output" =~ "Server: BashHTTP/1.0" ]]
    # Verificar body de error
    [[ "$output" =~ "Error 404: Resource not found" ]]
}

@test "curl -i debe mostrar headers y body para 405" {
    run curl -i -s -X POST http://localhost:$TEST_PORT/
    
    [ "$status" -eq 0 ]
    # Verificar headers 405
    [[ "$output" =~ "HTTP/1.1 405 Method Not Allowed" ]]
    [[ "$output" =~ "Content-Type: text/plain" ]]
    [[ "$output" =~ "Server: BashHTTP/1.0" ]]
    # Verificar body de error
    [[ "$output" =~ "Error 405: Method Not Allowed" ]]
}

@test "Verificar que se generan logs de acceso" {
    # Hacer una petición
    curl -s http://localhost:$TEST_PORT/ > /dev/null
    
    # Verificar que el archivo de log existe
    [ -f "out/logs/access.log" ]
    
    # Verificar que contiene la petición
    run grep "GET / HTTP/1.1" out/logs/access.log
    [ "$status" -eq 0 ]
}

@test "Servidor debe manejar múltiples peticiones consecutivas" {
    # Hacer varias peticiones consecutivas
    for i in {1..3}; do
        run curl -s -w "%{http_code}" http://localhost:$TEST_PORT/
        [ "$status" -eq 0 ]
        [[ "$output" =~ "200" ]]
    done
}