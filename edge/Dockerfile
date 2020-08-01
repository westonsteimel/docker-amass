ARG REVISION
ARG CREATED
ARG VERSION
ARG GIT_REF="${VERSION}"

FROM golang:alpine AS builder

ARG GIT_REF
ARG VERSION
ENV VERSION="${VERSION}"
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GO111MODULE=on

RUN	apk upgrade && apk --no-cache add \
	ca-certificates \
    git \
    make \
    && rm -rf /var/cache

RUN mkdir -p /go/src/amass \
    && git clone --depth 1 --branch "${GIT_REF}" https://github.com/OWASP/Amass.git /go/src/amass \
	&& cd /go/src/amass \
    && go install -ldflags '-s -w' ./... \
	&& cp -vr /go/bin/* /usr/local/bin/ \
	&& if [$TARGETPLATFORM = "linux/amd64"]; then apk add --no-cache upx && upx --lzma --best /usr/local/bin/amass; fi \
    && echo "Build complete."

RUN addgroup amass \
    && adduser -G amass -s /bin/sh -D amass

FROM scratch

ARG VERSION
ARG SOURCE
ARG REVISION
ARG CREATED

COPY --from=builder /usr/local/bin/amass /usr/bin/amass
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

USER amass

ENTRYPOINT [ "/usr/bin/amass" ]

LABEL org.opencontainers.image.title="amass" \
    org.opencontainers.image.description="amass in Docker" \ 
    org.opencontainers.image.source="${SOURCE}" \
    org.opencontainers.image.revision="${REVISION}" \
    org.opencontainers.image.created="${CREATED}" \
    org.opencontainers.image.version="${VERSION}"
