#!/bin/bash
#
# Docker entrypoint for mx2-simple

if [ ! -d /etc/letsencrypt/live/ ] ; then
	echo "Getting Certificate for $(hostname)"
	certbot certonly --standalone --preferred-challenges http -d $(hostname) --non-interactive --agree-tos -m admin@$(hostname -d)
fi

certpath="/etc/letsencrypt/live/$(hostname)"
if [ -d $certpath ] ; then
	busybox crond
fi

if [ "$(postconf -h  relayhost)" == "" ] ; then
	echo "Configuring postfix as relay for ${RELAY_DOMAINS} (relay host ${RELAY_HOST})"
	postconf smtpd_recipient_restrictions=reject_unauth_destination &&\
	postconf smtpd_relay_restrictions=reject_unauth_destination &&\
	postconf relay_domains=${RELAY_DOMAINS} &&\
	postconf relayhost=${RELAY_HOST} &&\
	postconf recipient_delimiter=+ &&\
	postconf maximal_queue_lifetime=10d
	
	if [ -f /etc/postfix/relay_recipients ] ; then
		# must be owned by root
		chown root.root /etc/postfix/relay_recipients
		chmod 644 /etc/postfix/relay_recipients
		postmap /etc/postfix/relay_recipients
		postconf relay_recipient_maps=hash:/etc/postfix/relay_recipients
	fi
	
	if [ -d $certpath ] ; then
		postconf smtpd_tls_cert_file=${certpath}/fullchain.pem
		postconf smtpd_tls_key_file=${certpath}/privkey.pem
		postconf smtpd_tls_security_level=may
	else
		echo "WARNING: No TLS encryption support! ${certpath} missing"
	fi
fi

busybox syslogd -O /dev/console

exec postfix start-fg
