FROM alpine:latest

RUN apk add postfix certbot bash
COPY entrypoint.sh cert-renew-hook.sh /
COPY cert-renew.sh /etc/periodic/weekly/

VOLUME /var/spool/postfix
EXPOSE 25 80

ENTRYPOINT [ "/entrypoint.sh" ]
