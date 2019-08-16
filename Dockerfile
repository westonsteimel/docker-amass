ARG AMASS_VERSION="3.0.18"

FROM golang:alpine AS builder

RUN	apk upgrade && apk --no-cache add \
	ca-certificates \
    git \
    make \
    && rm -rf /var/cache
    
ARG AMASS_VERSION
ENV AMASS_VERSION "${AMASS_VERSION}"

RUN mkdir -p /go/src/amass \
	&& go get -u github.com/OWASP/Amass/... \
    && git clone --depth 1 --branch "${AMASS_VERSION}" https://github.com/OWASP/Amass.git /go/src/amass \
	&& cd /go/src/amass \
    && go install ./... \
	&& cp -vr /go/bin/* /usr/local/bin/ \
	&& echo "Build complete." \
    && addgroup amass \
    && adduser -G amass -s /bin/sh -D amass

FROM alpine:edge

ARG AMASS_VERSION

COPY --from=builder /usr/local/bin/amass /usr/bin/amass
COPY --from=builder /go/src/github.com/OWASP/Amass/wordlists /home/amass/.amass/wordlists
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

USER amass

ENTRYPOINT [ "/usr/bin/amass" ]

LABEL org.opencontainers.image.title="amass" \
    org.opencontainers.image.description="amass in Docker" \ 
    org.opencontainers.image.url="https://github.com/westonsteimel/docker-amass" \ 
    org.opencontainers.image.source="https://github.com/westonsteimel/docker-amass" \
    org.opencontainers.image.version="${AMASS_VERSION}"
