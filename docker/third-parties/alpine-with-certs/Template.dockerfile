FROM alpine

COPY ./dl-cdn-alpinelinux-org-chain.pem /root/my-root-ca.crt
RUN cat /root/my-root-ca.crt >> /etc/ssl/certs/ca-certificates.crt
RUN apk --no-cache add ca-certificates \
 && rm -rf /var/cache/apk/*
COPY ./dl-cdn-alpinelinux-org-chain.pem /usr/local/share/ca-certificates

RUN update-ca-certificates \
 && apk update \
 && apk upgrade