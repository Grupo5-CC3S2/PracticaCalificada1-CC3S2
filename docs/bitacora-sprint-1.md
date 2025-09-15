<<<<<<< HEAD
# Bitacora para sprint 1

- **Estudiante 1**: Jhon Cruz Tairo
- **Estudiante 2**: Daren Herrera Romo
- **Estudiante 3**: Anthony Carlos Ramón

## Estudiante 1

## Estudiante 2

- Para el funcionamiento del script `generate_cert.sh` se debe definir la variable de entorno `DOMAIN`

    ```bash
    export DOMAIN=localhost # Ejemplo
    ```

    > El valor es el que será usado como CN (Common Name) en el certificado. Al menos por ahora, consideré a `localhost` como CN.

- También se empleó el siguiente comando para la creación de clave y certificado:

    ```bash
    openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout "$KEY_FILE" -out "$CRT_FILE" -days 365 \
        -subj "/CN=${DOMAIN}" > /dev/null 2>&1
    ```

    > Se genera un certificado autofirmado (`-x509`) en `CRT_FILE` (`out/certs/dominio.crt`) y la clave privada de 2048 bits en `KEY_FILE` (`out/certs/dominio.key`)

**Decisiones tomadas**

- Se optó por no crear usuarios reales en el sistema para garantizar reproducibilidad
- En su lugar, se simularon roles con arrays y funciones en Bash. El resultado se almacenó en `out/sim/rol`, se simula cómo cada rol solo tiene acceso a ciertos archivos. Se consideraron dos roles: `root` y `auditor`
- Se aplicaron permisos (con `chmod`, 600 y 644) para los archivos creados

## Estudiante 3

- Para levantar el servidor se definió el puerto y el mensaje por defecto:
   ```
  PORT=8080
  MESSAGE = "Servidor HTTP en Bash"
   ```

- Para verificar que todas las herramientas necesarias estuvieran implementó el target `tools`. Ejecutando el comando `make tools`, se obtuvo:
   ```
  Verificando herramientas...
  nc disponible
  curl disponible
  dig disponible
  openssl disponible
  bats disponible
   ```
  Esto indica que todas las dependencias se encuentran instaladas.
  
- Construcción del proyecto, se creó el paquete comprimido con el comando `make build`, al ejecutar este comando da como resultado `dist/servidor.tar.gz` con el código fuente y documentación.

- Ejecución de pruebas con el comando `make test`
   ```
  Ejecutando pruebas...
   HTTP responde 200
   HTTP responde 404
  2 tests, 0 failures
   ```
  El anterior resultado indica que las pruebas pasaron exitosamente.

- Evidencias HTTP, con el servidor en ejecución con el comando `make evidences`

  Archivos generados:
  - `out/curl_root.txt` → respuesta al acceso `/`
  - `out/curl_404.txt` → respuesta simulando un 404

- Con el comando `make clean`, se eliminan las carpetas `out/` y `dist/` que contienen las evidencias generadas(`curl_root.txt`, `curl_404.txt`) y el paquete comprimido (`servidor.tar.gz`) generado en el `make build`, respectivamente.

**Decisiones tomadas**
- Se mantuvieron las variables de entorno con valores simples (`localhost`, `8080`) para facilitar la reproducibilidad.
- No se añadieron dependencias adicionales más allá de las verificadas en make tools.
- Las evidencias se generaron en la carpeta `out/` para mantener separado el código fuente de los resultados.


>>>>>>> 11c8ef9 (Correciones del makefile y bitacora del sprint 1(estudiante 3))
