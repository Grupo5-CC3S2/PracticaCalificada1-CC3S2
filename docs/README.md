# Automatización de despliegue de un servidor web simple con seguridad TLS

## Integrantes:

- Daren Herrera Romo (scptx0)
- Jhon Cruz Tairo (JECT-02)
- Anthony Carlos Ramón (AnthonyCar243)

## Instrucciones de uso

### Instruciones generales

- Verificación de que se poseen todas las herramientas:

    ```bash
    make tools
    ```

- Para ver más información sobre el uso:

    ```bash
    make help
    ```

- Para generar todas las evidencias o salidas (antes habiendo levantado los servidores HTTP y TLS):

    ```bash
    make evidences
    ```

- Ejecutar todas las pruebas

    ```bash
    make tests
    ``` 

### TLS

1. Generar los certificados para la conexión TLS

    ```bash
    make generate-certs
    ```

2. Levantar servidor TLS

    ```bash
    make run-tls-server
    ```

3. Verificaciones y generación de evidencias

    ```bash
    make curl-tls
    make tls-handshake
    ```

4. Pruebas (solo para TLS)

    ```
    bats tests/tls_tests.bats
    ``` 

## Variables de entorno

El proyecto utiliza las siguientes variables de entorno:

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `PORT`   | Puerto en el que corre el servidor web | 8080 |
| `MESSAGE`   | Puerto en el que corre el servidor web | Servidor HTTP en Bash |
| `DOMAIN`   | Dominio que usan los servidores | localhost |

## Contrato de salidas

Ver archivo `contrato-salidas.md`