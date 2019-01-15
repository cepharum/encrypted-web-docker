#!/bin/bash

NOSSL="${1}"

if [ -n "$NOSSL" ]; then
	cat /proxy/http.conf >/etc/nginx/conf.d/proxy.conf
else
	cat /proxy/http.conf /proxy/https.conf >/etc/nginx/conf.d/proxy.conf
fi

exec nginx -g "daemon off;"
