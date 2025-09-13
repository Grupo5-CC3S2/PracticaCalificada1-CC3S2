#!/bin/bash

# src/dns_check.sh

set -euo pipefail

# Crea out en caso no exista
mkdir -p out

# ejecuta dig de un dominio como en este caso google
dig www.google.com > out/dig_output.txt