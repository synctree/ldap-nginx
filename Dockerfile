FROM nginx
MAINTAINER Synctree Appforce

RUN mkdir -p /usr/proxy/configs

ADD configs /usr/proxy/configs/
ADD docker/etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD docker/usr/bin/* /usr/bin/
ADD docker/docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /usr/proxy

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "bash" ]
