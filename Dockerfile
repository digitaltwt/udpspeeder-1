FROM alpine:3.6

ARG TZ='Asia/Shanghai'

ENV TZ $TZ
ENV SS_LIBEV_VERSION 3.1.1
ENV KCP_VERSION 20171129 
ENV UDP_VERSION v2@20171125.0

RUN apk upgrade --update \
    && apk add bash tzdata libsodium iptables net-tools \
    && apk add --virtual .build-deps \
        autoconf \
        automake \
        asciidoc \
        xmlto \
        build-base \
        curl \
        libev-dev \
        libtool \
        c-ares-dev \
        linux-headers \
        udns-dev \
        libsodium-dev \
        mbedtls-dev \
        pcre-dev \
        udns-dev \
        tar \
        git \
    && curl -sSLO https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_LIBEV_VERSION/shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz \
    && tar -zxf shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz \
    && (cd shadowsocks-libev-$SS_LIBEV_VERSION \
    && ./configure --prefix=/usr --disable-documentation \
    && make install ) \
    && curl -sSLO https://github.com/wangyu-/UDPspeeder/releases/download/$UDP_VERSION/speederv2_binaries.tar.gz \
    && tar -zxf speederv2_binaries.tar.gz \
    && mv speederv2_amd64 /usr/bin/speederv2 \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
        )" \
    && apk add --no-cache --virtual .run-deps $runDeps \
    && apk del .build-deps \
    && rm -rf speederv2_binaries.tar.gz \
        shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz \
        shadowsocks-libev-$SS_LIBEV_VERSION \
        /var/cache/apk/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
