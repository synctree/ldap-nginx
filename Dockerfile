FROM ubuntu:14.04
MAINTAINER Synctree Appforce

RUN apt-get update \
  && apt-get install -y \
    git \
    wget \
    curl \
    gnupg \
    unzip \
    libgd-dev \
    supervisor \
    libxslt-dev \
    libperl-dev \
    libgeoip-dev \
    libldap2-dev \
    build-essential \
  && apt-get clean

RUN mkdir -p /usr/proxy/configs /usr/proxy/dependencies /usr/proxy/ldap-auth-module

WORKDIR /usr/proxy

# NGINX dependencies:
# PCRE
# zlib
# openssl

# PCRE
RUN cd /usr/proxy/dependencies \
  && wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.39.tar.gz \
  && tar -zxf pcre-8.39.tar.gz \
  && cd pcre-8.39 \
  && ./configure \
  && make \
  && make install

# zlib
RUN cd /usr/proxy/dependencies \
  && wget http://zlib.net/zlib-1.2.8.tar.gz \
  && tar -zxf zlib-1.2.8.tar.gz \
  && cd zlib-1.2.8 \
  && ./configure \
  && make \
  && make install

# openssl
RUN cd /usr/proxy/dependencies \
  && wget http://www.openssl.org/source/openssl-1.0.2j.tar.gz \
  && tar -zxf openssl-1.0.2j.tar.gz \
  && cd openssl-1.0.2j \
  && ./config --prefix=/usr \
  && make \
  && make install

# nginx-auth-ldap
RUN cd /usr/proxy/dependencies \
  && wget https://github.com/kvspb/nginx-auth-ldap/archive/master.zip -O nginx-auth-ldap.zip \
  && unzip nginx-auth-ldap.zip \
  && mv nginx-auth-ldap-master nginx-auth-ldap

# NGINX stable
RUN cd /usr/proxy/dependencies \
  && wget http://nginx.org/download/nginx-1.10.2.tar.gz \
  && tar zxf nginx-1.10.2.tar.gz \
  && cd nginx-1.10.2 \
  && ./configure \
    --sbin-path=/usr/local/nginx/nginx \
    --conf-path=/usr/local/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --with-pcre=../pcre-8.39 \
    --with-zlib=../zlib-1.2.8 \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_perl_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_v2_module \
    --with-ipv6 \
    --add-module=/usr/proxy/dependencies/nginx-auth-ldap \
  && make \
  && make install

RUN mkdir -p /usr/local/nginx/conf.d /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp

ADD configs /usr/proxy/configs/
RUN mv /usr/local/nginx/nginx.conf /usr/local/nginx/nginx.conf.ORIG
ADD docker/etc/nginx/nginx.conf /usr/local/nginx/nginx.conf
ADD docker/usr/bin/* /usr/bin/
ADD docker/docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "bash" ]
