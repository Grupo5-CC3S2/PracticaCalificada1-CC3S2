# Bitacora para sprint 2

- **Estudiante 1**: Jhon Cruz Tairo
- **Estudiante 2**: Daren Herrera Romo
- **Estudiante 3**: Anthony Carlos Ramón

## Estudiante 1

Inicializamos con shellcheck para detectar errores en el sprint 1

```console
ject@pop-os:~/Escritorio/PCsDS/PracticaCalificada1-CC3S2$ shellcheck src/server/server.sh

In src/server/server.sh line 25:
  trap "rm -f '$pipe'; exit" INT TERM EXIT
               ^---^ SC2064 (warning): Use single quotes, otherwise this expands now rather than when signalled.


In src/server/server.sh line 27:
  nc -l -p "$PORT" <"$pipe" | (
                    ^-----^ SC2094 (info): Make sure not to read and write the same file in the same pipeline.


In src/server/server.sh line 64:
  ) >"$pipe"
     ^-----^ SC2094 (info): Make sure not to read and write the same file in the same pipeline.
```
usar "" hace que la variable $pipe se expanda inmediatamente en lugar de expandirse cuando la señal ocurra, **CORREGIDO**

- Implementacion de la mejora en servicios HTTP para manejar metodos **GET** y **HEAD**, adicionalmente se validan codigos **HTTP** con `curl -i`

- Incluye implementacion de test http en `src/tests/http_tests.bats` con todas las pruebas pasadas.

- Finalmente inplementacion de `dns_check.sh` que resuelve **DNS** usando dig de forma local y se guarda salidas en `out/dns`, considere las siguientes variables:

```bash
DOMAINS=("google.com" "github.com" "stackoverflow.com" "cloudflare.com" "amazon.com")
CNAME_DOMAINS=("www.github.com" "www.stackoverflow.com" "www.reddit.com" "www.netflix.com")
DNS_SERVERS=("8.8.8.8" "1.1.1.1" "208.67.222.222")
```