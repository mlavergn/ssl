###############################################
#
# Makefile
#
# Covers SSH / RSA : EC / APNS
###############################################

DOMAIN ?= example.com
NAME   ?= demo
EMAIL  ?= admin@$(DOMAIN)

DAYS   ?= 3650

#
# Subject info
#

ORG     := Example\ Inc.
DEPT    := IT
CITY    := San\ Francisco
STATE   := California
COUNTRY := US
HOST    := $(NAME).$(DOMAIN)
ALT     := $(NAME)-alt.$(DOMAIN)

SUBJ   := '/O=$(ORG)/OU=$(DEPT)/C=${COUNTRY}/ST=$(STATE)/L=$(CITY)/CN=$(HOST)/subjectAltName=$(ALT)/emailAddress=$(EMAIL)'

subj:
	@echo $(SUBJ)

#
# SSH
# recommended key 2048 (or 4096)
#

SSHKEY := 2048

ssh:
	ssh-keygen -t rsa -b $(SSHKEY) -C "$(EMAIL)"

#
# RSA
# recommended key 2048
#

RSAKEY := 2048

rsapriv:
	openssl genrsa -out $(NAME).key $(RSAKEY)

csr:
	openssl req -new -subj $(SUBJ) -key $(NAME).key -out $(NAME).csr

rsapub:
	openssl x509 -req -days $(DAYS) -in $(NAME).csr -signkey $(NAME).key -out $(NAME).crt

rsa: rsapriv csr rsapub

rsacheck:
	openssl req -in $(NAME).csr -text -noout
	openssl req -in $(NAME).csr -noout -verify -key $(NAME).key

#
# EC
# recommended key secp384r1 
#

ECKEY := secp384r1

ectype:
	openssl ecparam -list_curves

ecpriv:
	openssl ecparam -name $(ECKEY) -genkey -param_enc explicit -out $(NAME).key

ecpub:
	openssl req -new -nodes -subj $(SUBJ) -x509 -days $(DAYS) -key $(NAME).key -out $(NAME).crt

ec: ecpriv ecpub

eccheck:
	openssl ec -in $(NAME).key -text -noout

#
# Tests
#

ECOPTS := -sigalgs ECDSA+SHA384:ECDSA+SHA256 -verify 1 -named_curve secp384r1

browser:
	open https://localhost:8443/static/cors.html

www: browser
	openssl s_server -key $(NAME).key -cert $(NAME).crt -WWW -tls1_2 -accept 8443

cli:
	openssl s_client -debug -connect localhost:8443 -prexit -showcerts

#
# Cleanup
#

clean:
	-rm -rf *.key *.csr *.crt *.pem letsencrypt

#
# Signing
#

DRYRUN ?= --dry-run

certbot:
	sudo bash -c "pip install certbot"

cacert:
	mkdir -p certbot
	certbot certonly $(DRYRUN) --standalone --domain "$(HOST)" --csr $(NAME).csr --config-dir certbot --logs-dir certbot --work-dir certbot

carenew:
	certbot renew $(DRYRUN)

#
# AWS
#

aws:
	aws iam upload-server-certificate --server-certificate-name $(HOST) --certificate-body file://$(NAME).crt --private-key file://$(NAME).key --certificate-chain file://$(NAME).cacrt
