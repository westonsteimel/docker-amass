#!/bin/sh

VERSION=$(grep -e "ARG AMASS_VERSION=" stable/Dockerfile)
VERSION=${VERSION#ARG AMASS_VERSION=\"}
VERSION=${VERSION%\"}
echo "Tagging version ${VERSION}"
docker tag "${DOCKER_USERNAME}/amass:latest" "${DOCKER_USERNAME}/amass:${VERSION}"
