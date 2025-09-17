#!/usr/bin/env bats

# Tests para verificación DNS - Sprint 3
# Archivo: tests/dns_tests.bats

setup() {
    # Crear directorio de salida
    mkdir -p out/dns
}

teardown() {
    # Limpiar archivos de log después de las pruebas
    rm -f out/dns/dns_results.log
}

@test "El script dns_check.sh se ejecuta sin errores" {
    run bash src/dns/dns_check.sh
    [ "$status" -eq 0 ]
}

@test "Se crea el archivo de log dns_results.log" {
    run bash src/dns/dns_check.sh
    [ -f "out/dns/dns_results.log" ]
}

@test "El log contiene la sección de registros A" {
    bash src/dns/dns_check.sh
    run grep -q "=== REGISTROS A ===" out/dns/dns_results.log
    [ "$status" -eq 0 ]
}

@test "El log contiene la sección de registros CNAME" {
    bash src/dns/dns_check.sh
    run grep -q "=== REGISTROS CNAME ===" out/dns/dns_results.log
    [ "$status" -eq 0 ]
}

@test "El log contiene la sección de prueba de servidores DNS" {
    bash src/dns/dns_check.sh
    run grep -q "=== PRUEBA SERVIDORES DNS ===" out/dns/dns_results.log
    [ "$status" -eq 0 ]
}

@test "Al menos un registro A se resolvió (contiene una IP)" {
    bash src/dns/dns_check.sh
    # Buscar una línea que tenga el formato de IP
    run grep -E "  - [^ ]+ -> [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" out/dns/dns_results.log
    [ "$status" -eq 0 ]
}

@test "Al menos un servidor DNS respondió (tiempo de respuesta registrado)" {
    bash src/dns/dns_check.sh
    # Buscar línea con tiempo de respuesta
    run grep -E "  - Tiempo: [0-9]+ msec" out/dns/dns_results.log
    [ "$status" -eq 0 ]
}

@test "El script maneja correctamente dominios sin resolución" {
    # Probar con un dominio improbable que no exista
    run dig +short "dominio-inexistente-$(date +%s).test" A
    [ "$status" -eq 0 ]
    # Verificar que el script no falla con dominios no resolubles
    run bash src/dns/dns_check.sh
    [ "$status" -eq 0 ]
}