FROM alpine:3.4
MAINTAINER Ralf Schimmel <ralf@gynzy.com>

COPY cacher.sh /usr/local/
RUN mkdir /cache && apk add --no-cache bash rsync && chmod 755 /usr/local/cacher.sh

ENTRYPOINT ["/usr/local/cacher.sh"]
