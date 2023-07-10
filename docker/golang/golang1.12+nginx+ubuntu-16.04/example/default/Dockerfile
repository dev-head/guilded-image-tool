FROM examplecom-golang1.2-nginx:ubuntu-16.04

ENV GOPATH=/go
ENV GOCACHE=${GOPATH}/cache
ARG GOPATH=${GOPATH:-/go}

WORKDIR /go

COPY conf/supervisor-program.conf /etc/supervisor/conf.d/supervisor-program.conf
COPY conf/nginx.vhost.conf /etc/nginx/sites-available/default
COPY src/main.go ${GOPATH}/src/main.go