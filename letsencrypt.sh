#!/bin/sh

if [ -z "${DOMAIN}" ]; then
	echo "missing domain name in environment variable \$DOMAIN" >&2
	exit 1
fi

case "${1}" in
	initialize)
		cd /opt/certbot
		certbot certonly --webroot --agree-tos -w /var/lib/letsencrypt -d "$DOMAIN"
		;;

	renew)
		cd /opt/certbot
		certbot renew
		;;

	*)
		echo "missing or invalid action, invoke either with 'initialize' or 'renew'" >&2
		exit 1
esac
