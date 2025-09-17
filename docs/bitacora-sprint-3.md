# Bitácora para sprint 3

- **Estudiante 1**: Jhon Cruz Tairo
- **Estudiante 2**: Daren Herrera Romo
- **Estudiante 3**: Anthony Carlos Ramón

## Estudiante 1

- Se implementaros las pruebas automatizadas con **Bats** para las peticiones HTTP y resolucion DNS con dig. Los tests se encuentran en `tests/dns_tests.bats` y `tests/http_tests.bats`

```console
# make test ejecuta todos los tests en /tests/
```
todos los tests pasan de manera satisfactoria

## Estudiante 2

- Se implementaron las pruebas automatizadas con **Bats** para validar el correcto funcionamiento del servidor TLS. Los tests se encuentran en `tests/tls_tests.bats`, para ejecutarlos, podemos emplear:

```
# Ejecuta todos los tests, incluidos los del servidor http
make tests 
# Ejecuta solo el test de TLS
bats tests/tls_tests.bats
```

**Decisiones tomadas**

- Se utilizó `curl -sk` para probar conexiones HTTPS ignorando la validación del certificado autofirmado
- Se usó `bash -c` en los tests que necesitaban tuberías (`|`) para compatibilidad con la sintaxis de Bats.

## Estudiante 3