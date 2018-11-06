###############################################
#
# Makefile
#
###############################################

DOMAIN = example.disney.com

COUNTRY = US
STATE = California
CITY = Burbank
ORG = Disney
DEPT = WDPR

EMAIL = marc.lavergne@disney.com

csr:
	openssl req -new -newkey rsa:2048 -nodes -keyout ${DOMAIN}.key -out ${DOMAIN}.csr -subj "/emailAddress=${EMAIL}/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/OU=${DEPT}/CN=${DOMAIN}"

private:
	openssl rsa -in ${DOMAIN}.key -outform PEM > ${DOMAIN}.private.pem

stest:
	openssl s_server -key ${DOMAIN}.key -cert ${DOMAIN}.crt -www -accept 10443

ctest:
	openssl s_client -debug -connect 127.0.0.1:10443 -prexit

aws:
	aws iam upload-server-certificate --server-certificate-name ${DOMAIN} --certificate-body file://${DOMAIN}.crt --private-key file://${DOMAIN}.private.pem --certificate-chain file://server.chain
