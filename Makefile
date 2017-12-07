#! make

all: init build up

init:

build:
	docker build -t bioatlas/servermonitor:latest .

up:
	docker-compose up -d
	sleep 5 
	xdg-open https://monitor.bioatlas.se &
	xdg-open https://portainer.bioatlas.se &

down:
	docker-compose down

ssl-certs:
	@echo "Generating SSL certs using https://hub.docker.com/r/paulczar/omgwtfssl/"
	docker run -v /tmp/certs:/certs \
		-e SSL_SUBJECT=bioatlas.se \
		-e SSL_DNS=monitor.bioatlas.se,portainer.bioatlas.se \
	paulczar/omgwtfssl
	cp /tmp/certs/cert.pem certs/bioatlas.se.crt
	cp /tmp/certs/key.pem certs/bioatlas.se.key

	@echo "Using self-signed certificates will require either the CA cert to be imported system-wide or into apps"
	@echo "if you don't do this, apps will fail to request data using SSL (https)"
	@echo "WARNING! You now need to import the /tmp/certs/ca.pem file into Firefox/Chrome etc"
	@echo "WARNING! For curl to work, you need to provide '--cacert /tmp/certs/ca.pem' switch or SSL requests will fail."

ssl-certs-clean:
	rm -f certs/bioatlas.se.crt certs/bioatlas.se.key
	rm -f /tmp/certs

ssl-certs-show:
	#openssl x509 -in certs/dina-web.net.crt -text
	openssl x509 -noout -text -in certs/bioatlas.se.crt
