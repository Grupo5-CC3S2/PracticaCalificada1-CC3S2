# Bitacora para sprint 1

- **Estudiante 1**: Jhon Cruz Tairo
- **Estudiante 2**: Daren Herrera Romo
- **Estudiante 3**: Anthony Carlos Ramón


## Estudiante 1

## Estudiante 2

- Para generar  certificado y clave privada autofirmados.

	```bash
	make generate-certs
	```

	Internamente ejecuta el script `generate_certs.sh`. Tener en cuenta que el predeterminado (si ejecutamos el script a través del makefile), es el dominio `localhost`

- Para levanta el servidor TLS:

	```bash
	make run-tls-server
	```

	Internamente ejecuta el script `tls_server.sh`.  Tener en cuenta que el predeterminado (si ejecutamos el script a través del makefile), es el dominio `localhost` y el puerto 8443.

- Para mostrar evidencias de conexión TLS con `curl -k`.

	```bash
	make curl-tls
	```

	Los resultados se guardan en `out/tls/curl_tls.txt`. Parte de la salida es:

	```html
	<HTML><BODY BGCOLOR="#ffffff">
	<pre>
	
	s_server -cert /home/yo/PC1/PracticaCalificada1-CC3S2/out/certs/localhost.crt -key /home/yo/PC1/PracticaCalificada1-CC3S2/out/certs/localhost.key -accept 8443 -www 
	Secure Renegotiation IS supported
	Ciphers supported in s_server binary
	TLSv1.3    :TLS_AES_256_GCM_SHA384    TLSv1.3    :TLS_CHACHA20_POLY1305_SHA256 
	...  
	```

- Para mostrar evidencia del handshake TLS con `openssl s_client`.
        
	```bash
	make handshake-tls
	```

	Los resultados se guardan en`out/tls/tls-handshake.txt`. Parte de la salida es:

	```txt
	depth=0 CN = localhost
	verify error:num=18:self-signed certificate
	verify return:1
	depth=0 CN = localhost
	verify return:1
	CONNECTED(00000003)
	---
	Certificate chain
	 0 s:CN = localhost
	   i:CN = localhost
	   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
	   v:NotBefore: Sep 16 22:26:43 2025 GMT; NotAfter: Sep 16 22:26:43 2026 GMT
	---
	Server certificate
	-----BEGIN CERTIFICATE-----
	```

**Decisiones tomadas**

- Se optó por usar `localhost` como CN en el certificado para asegurar coincidencia con las pruebas
- No se modificó `/etc/hosts`, lo que hace que la reproducibilidad sea más sencilla en cualquier máquina
- `ss -ltnp` puede emplearse como evidencia de que el servidor TLS abre un socket en el puerto 8443

## Estudiante 3