#!/bin/bash -e

# fail on unset variables expansion
set -o nounset

if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    TAG="$DOCKER_PROJECT:$DOCKER_IMAGE_TAG"
else
    TAG="$DOCKER_PROJECT:dev.$TRAVIS_BRANCH-$DOCKER_IMAGE_TAG"
fi

echo "Building image $TAG"
docker build -f "$DOCKERFILE" $ARGS -t "$TAG" .
