FROM golang:1.9.2-alpine as build

ENV http_proxy=http://geapproxy03.vm.cipal.net:3128
ENV https_proxy=http://geapproxy03.vm.cipal.net:3128

RUN apk --no-cache add glide git && \
    go get -v github.com/kardianos/govendor

WORKDIR /go/src/github.com/jmendiara/prometheus-swarm-discovery

COPY *.go ./
COPY glide.* ./

RUN glide install
RUN go install

FROM alpine
LABEL maintainer="javier.mendiaracanardo@telefonica.com"

COPY --from=build /go/bin/prometheus-swarm-discovery /prometheus-swarm-discovery

ARG proxy=http://geapproxy03.vm.cipal.net:3128

RUN http_proxy=${proxy} https_proxy=${proxy} apk update
RUN http_proxy=${proxy} https_proxy=${proxy} apk add docker

ENV GIN_MODE release
EXPOSE 8080

ENTRYPOINT [ "/prometheus-swarm-discovery"]
CMD ["server"] 


