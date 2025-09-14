# Makefile basico para ejecucion de tareas
PORT ?= 8080
MESSAGE ?= Hello World

run-server:
	PORT=$(PORT) MESSAGE="$(MESSAGE)" bash src/server/server.sh

# Para las evidencias se ejecuta un servidor en segundo plano, luego elimina el servidor
evidences-curl:
	@mkdir -p out
	@curl -s http://localhost:$(PORT)/ > out/curl_root.txt
	@curl -s http://localhost:$(PORT)/bad > out/curl_404.txt
	@cat out/curl_root.txt
	@cat out/curl_404.txt

# evidencias completas, asume que el servidor se esta ejecutando para curl
evidences: run-dns evidences-curl