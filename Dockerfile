FROM ubuntu:14.04
MAINTAINER Synctree Appforce

RUN apt-get update \
  && apt-get install -y \
    git \
    wget \
    unzip \
    supervisor \
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
    --pid-path=/usr/local/nginx/nginx.pid \
    --with-pcre=../pcre-8.39 \
    --with-zlib=../zlib-1.2.8 \
    --with-http_ssl_module \
    --with-stream \
    --add-module=/usr/proxy/dependencies/nginx-auth-ldap \
  && make \
  && make install

RUN mkdir -p /usr/local/nginx/conf.d

ADD configs /usr/proxy/configs/
RUN mv /usr/local/nginx/nginx.conf /usr/local/nginx/nginx.conf.BAK
ADD docker/etc/nginx/nginx.conf /usr/local/nginx/nginx.conf
ADD docker/usr/bin/* /usr/bin/
ADD docker/docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "bash" ]
