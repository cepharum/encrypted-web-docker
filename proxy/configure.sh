#!/bin/bash

PRIMARY="${DOMAIN%%,*}" && \
ADDITIONAL="${DOMAIN#*,}" && \

if [ "$PRIMARY" != "$ADDITIONAL" ]; then
	sed "s/%%PRIMARY%%/$PRIMARY/" </proxy/http-multi.conf >/proxy/http.conf
	sed "s/%%PRIMARY%%/$PRIMARY/" </proxy/https-multi.conf >/proxy/https.conf
fi

rm /proxy/http-multi.conf /proxy/https-multi.conf
