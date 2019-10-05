#!/usr/bin/env bash

# fail this script if a command fails
set -e

export DOCKER_TAG_SEPARATOR='  ;  '
export kREGEX_TAG='^[0-9]+\.[0-9]+\.[0-9]+$'

if [ -z "$1" ]; then
  echo "Tag is required as parameter"
  exit 1
fi
GIT_TAG=$1
echo "GIT_TAG='${GIT_TAG}'"

if [ -z "$2" ]; then
  echo "Docker image is required as parameter"
  exit 1
fi
DOCKER_IMAGE=$2
echo "DOCKER_IMAGE='${DOCKER_IMAGE}'"

if [ -z "$DOCKER_PASSWORD" ]; then
  echo "DOCKER_PASSWORD ENV variable is required!"
  exit 1
fi

if [ -z "$DOCKER_USERNAME" ]; then
  echo "DOCKER_USERNAME ENV variable is required!"
  exit 1
fi

get_docker_tags() {
  if [ -z "$1" ]; then
    echo "git tag not specified to get_docker_tags"
    return 1
  fi

  if [[ $1 =~ $kREGEX_TAG ]]; then
    # split the tag
    IFS='.' read -r -a array <<<"$1"
    echo "latest${DOCKER_TAG_SEPARATOR}${array[0]}${DOCKER_TAG_SEPARATOR}${array[0]}.${array[1]}${DOCKER_TAG_SEPARATOR}$1"
  else
    # just return the tag
    echo "latest${DOCKER_TAG_SEPARATOR}${1}"
  fi
}

# DOCKER_USERNAME and DOCKER_PASSWORD have to be set in ENV
echo "login to docker hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

DOCKER_TAGS=$(get_docker_tags "${GIT_TAG}")
echo "Docker tags='$DOCKER_TAGS'"

export IFS="${DOCKER_TAG_SEPARATOR}"
for docker_tag in ${DOCKER_TAGS}; do
  if [[ ${docker_tag} != "latest" ]]; then
    echo "tagging docker image with tag='${docker_tag}'..."
    docker tag "${DOCKER_IMAGE}:latest" "${DOCKER_IMAGE}:${docker_tag}"
  fi

  echo "pushing docker image '${DOCKER_IMAGE}:${docker_tag}'..."
  docker push "${DOCKER_IMAGE}:${docker_tag}"
done
