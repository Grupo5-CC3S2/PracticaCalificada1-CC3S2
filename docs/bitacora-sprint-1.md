# Bitacora para sprint 1

- **Estudiante 1**: Jhon Cruz Tairo
- **Estudiante 2**: Daren Herrera Romo
- **Estudiante 3**: Anthony Carlos Ramón

## Estudiante 1
- Se implemento el script `src/server/server.sh` el cual inicializa un servidor basico totalmente en bash
- Se uso variables de entorno para pruebas en el makefile como:
```bash
PORT ?= 8080
MESSAGE ?= Servidor HTTP en Bash
```
a modo de probar si el servidor local funciona y responde peticiones de forma correcta
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