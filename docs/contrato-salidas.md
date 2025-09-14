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