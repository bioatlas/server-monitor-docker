# Server Monitoring and Container Management UIs

[![AGPLv3 License](http://img.shields.io/badge/license-AGPLv3-blue.svg) ](https://github.com/bioatlas/servermonitor-docker/blob/master/LICENSE)

This is a composition of services that make use of PHP Server Monitor for "external monitoring" of servers and that also provides Portainer as a web-based management interface for containers.

- <http://docs.phpservermonitor.org/en/latest/install.html>
- <https://portainer.io/overview.html>


## Requirements

The installation requires a docker host under your control, ie a machine with the `docker` daemon running, see <https://docs.docker.com/engine/installation/>. This host should configure name resolution, see <https://github.com/mskyttner/dns-test-docker#configuring-the-docker-daemon-on-the-host>

You also need to install `docker-compose`, see <https://docs.docker.com/compose/install/> and `make` and `git`. 


## Usage

First make sure that you copy your certs into a `certs` directory or use the Makefile to generate self-signed certs (see separate section on that further down).

Then use the `Makefile` which lists various useful targets providing shortcuts to use the composition of system services, for example you can build and start all services with ....

		make

The `docker-compose.yml` file defines the various components of the system.

# Certificates and setting up SSL

If you are using SSL certs that you have acquired commercially and those are signed by a CA, put your files, ie shared.crt (bioatlas.se.crt) and shared.key (bioatlas.se.key) in the 'certs' -directory.

You can also generate self-signed certs. Detailed steps:

		# on first run, you can use
		make

		# to generate self-signed certs use
		make ssl-certs

		# inspect ssl cert in use with
		make ssl-certs-show

## Commercial certs

If you have bought certs, put them in the certs directory and do NOT run `make ssl-certs` again, as that would overwrite those files.

If you bought certs, you may have several files available:

		key.pem - your secret key originally used in your Certificate Signing Request
		cacert.pem - the Certificate Authority's chain of certs
		cert.pem - your signed (wildcard?) public cert

If so, then combine the last two files - the cacert.pem och cert.pem - into `combined.pem`. In the right order. Pls search Internet for instructions.

## Self-signed certs

Using self-signed certificates will require either the CA cert to be imported and installed either system-wide or in each of your apps. If you don't do this, apps will fail to request data using SSL (https).

So, besides configuring those certs for use in the backend services, you also need to:

- import the /tmp/certs/ca.pem file into Firefox/Chrome or other browsers or clients that you are using on the client side

Pls search for documentation on how to do it, for example:

<https://support.mozilla.org/en-US/questions/995117>

NB: For curl to work, you need to provide '--cacert /tmp/certs/ca.pem' switch or SSL requests will fail. 







