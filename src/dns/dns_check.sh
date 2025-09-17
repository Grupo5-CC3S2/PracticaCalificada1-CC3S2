#!/usr/bin/env bash

set -euo pipefail

# Script para consultas DNS -Sprint2

# Crear directorio de salida
mkdir -p out/dns

# Variables de configuracion
DOMAINS=("google.com" "github.com" "stackoverflow.com" "cloudflare.com" "amazon.com")
CNAME_DOMAINS=("www.github.com" "www.stackoverflow.com" "www.reddit.com" "www.netflix.com")
DNS_SERVERS=("8.8.8.8" "1.1.1.1" "208.67.222.222")
LOG_FILE="out/dns/dns_results.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Inicializar log
echo "=== DNS Check iniciado - $TIMESTAMP ===" | tee "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Verificar disponibilidad de dig
if ! command -v dig >/dev/null 2>&1; then
    echo "Error: dig no está instalado. Instalar con: sudo apt-get install dnsutils" >&2
    exit 1
fi

# Función para registros A
check_a_records() {
    echo "=== REGISTROS A ===" | tee -a "$LOG_FILE"
    for domain in "${DOMAINS[@]}"; do
        echo "Consultando registro A para $domain:" | tee -a "$LOG_FILE" # imprime encabezado y evita trncamiento de fichero
        result=$(dig +short "$domain" A 2>/dev/null || echo "") # consulta DNS por registro y devuelve solo las respuestasen forma corta
        if [ -n "$result" ]; then # comprueba que el resultado no este vacio
            echo "$result" | while read -r ip; do # pasa las lineas de result al while read e imprime las IP
                echo "  - $domain -> $ip" | tee -a "$LOG_FILE"
            done
            ttl=$(dig "$domain" A 2>/dev/null | awk '/'"$domain"'.*IN.*A/ {print $2; exit}') # extraer tiempo de vida
            [ -n "$ttl" ] && echo "    TTL: $ttl segundos" | tee -a "$LOG_FILE" # si ttl no esta vacio imprime y registra
        else
            echo "  - $domain -> No se pudo resolver" | tee -a "$LOG_FILE" #en caso result esta vacio no se pudo resolver
        fi
        echo "" | tee -a "$LOG_FILE" # imprime y registra linea en blanco entre dominios
    done
}

# Función para registros CNAME
check_cname_records() {
    echo "=== REGISTROS CNAME ===" | tee -a "$LOG_FILE"
    for domain in "${CNAME_DOMAINS[@]}"; do
        echo "Consultando registro CNAME para $domain:" | tee -a "$LOG_FILE"
        result=$(dig +short "$domain" CNAME 2>/dev/null || echo "")
        if [ -n "$result" ]; then
            echo "  - $domain -> $result" | tee -a "$LOG_FILE"
            ttl=$(dig "$domain" CNAME 2>/dev/null | awk '/'"$domain"'.*IN.*CNAME/ {print $2; exit}')
            [ -n "$ttl" ] && echo "    TTL: $ttl segundos" | tee -a "$LOG_FILE"
        else
            echo "  - $domain -> No tiene registro CNAME" | tee -a "$LOG_FILE"
        fi
        echo "" | tee -a "$LOG_FILE"
    done
}

# Función para probar servidores DNS
check_dns_servers() {
    echo "=== PRUEBA SERVIDORES DNS ===" | tee -a "$LOG_FILE"
    test_domain="google.com"
    for dns_server in "${DNS_SERVERS[@]}"; do
        echo "Probando servidor DNS $dns_server:" | tee -a "$LOG_FILE"
        result=$(dig @"$dns_server" +short "$test_domain" A 2>/dev/null || echo "") # consulta dns al servidor @dns_Server
        if [ -n "$result" ]; then 
            response_time=$(dig @"$dns_server" "$test_domain" 2>/dev/null | grep "Query time:" | awk '{print $4}')
            # sin short para respuesta completa y obtenemos el tiempo
            echo "  - Respuesta: $result" | tee -a "$LOG_FILE" #imprime respuesta dns
            echo "  - Tiempo: ${response_time:-N/A} msec" | tee -a "$LOG_FILE" #imprime tiempo de consulta
        else
            echo "  - Error o timeout" | tee -a "$LOG_FILE"
        fi
        echo "" | tee -a "$LOG_FILE"
    done
}

# Ejecutar verificaciones
echo "Iniciando verificación DNS..." | tee -a "$LOG_FILE"
check_a_records
check_cname_records
check_dns_servers
echo "=== DNS Check completado - $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "$LOG_FILE"
