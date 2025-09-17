# Contrato de salidas

Este archivo es un listado de los artefactos generados, su formato y cómo validarlos. 

## Archivos generados

### Certificados y claves (out/certs/)
- `out/certs/<dominio>.key`
  - Formato: clave privada RSA 2048 bits.
  - Permisos: 600.
  - Validación: `file out/certs/<DOMAIN>.key`.

- `out/certs/<dominio>.crt`
  - Formato: certificado X.509 autofirmado.
  - Permisos: 644.
  - Validación: `file out/certs/<DOMAIN>.key`.

### Simulación de roles (out/sim/)
- `out/sim/root/`
  - Contiene clave privada y certificado (simulación de acceso root).
- `out/sim/auditor/`
  - Contiene solo el certificado público (simulación de acceso auditor).

### Evidencias TLS (out/tls/)
- `out/tls/curl_tls.txt`
  - Contiene salida de curl -k https://<DOMAIN>:<TLS_PORT>/

- `out/tls/tls-handshake.txt`
  - Contiene resultado de openssl s_client -connect <DOMAIN>:<TLS_PORT> -servername <DOMAIN>
  - Incluye detalle del handshake TLS y certificado recibido

  ### Evidencias HTTP (out/http/)
- `out/http/curl_root.txt`  
  - Contiene la salida de `curl -s http://localhost:<HTTP_PORT>/`.  
  - Validación: comprobar que incluya `200 OK: <MENSAJE_DEL_SERVIDOR>`.

- `out/http/curl_404.txt`  
  - Contiene la salida de `curl -s http://localhost:<HTTP_PORT>/bad`.  
  - Validación: comprobar que incluya `Error 404: Resource not found`.

### Evidencias DNS (out/dns/)
- `out/dns/dns_check.txt`  
  - Contiene resultados de consultas A, CNAME y TTL de los dominios probados.  
  - Validación: cada dominio debe tener al menos una IP o un CNAME válido.
