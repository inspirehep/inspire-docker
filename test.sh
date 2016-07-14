#!/bin/bash -e


retry() {
    "$@" || "$@" || exit $?
}


prepare() {
    git clone https://github.com/inspirehep/inspire-next.git
    pushd inspire-next
    retry sudo pip install docker-compose
    # Add docker-compose at the version specified in ENV.
    sudo rm -f /usr/local/bin/docker-compose
    curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose
    chmod +x docker-compose
    sudo mv docker-compose /usr/local/bin
    export PATH=$PATH:/usr/local/bin
}


cleanup_env() {
    docker-compose kill
    docker-compose rm -f
    sudo rm -rf /tmp/virtualenv
}


run_unit_tests() {
    echo "###### Running unit tests"
    cleanup_env
    echo "Available images"
    docker images
    retry docker-compose -f docker-compose.deps.yml run --rm pip
    docker-compose -f docker-compose.deps.yml run --rm assets
    docker-compose -f docker-compose.test.yml run --rm unit
    cleanup_env
}


run_integration_tests() {
    echo "###### Running integraiton tests"
    cleanup_env
    echo "Available images"
    docker images
    retry docker-compose -f docker-compose.deps.yml run --rm pip
    docker-compose -f docker-compose.deps.yml run --rm assets
    docker-compose -f docker-compose.test.yml run --rm integration
    cleanup_env
}


main() {
    if [[ "$TRAVIS_BRANCH" != "master" ]]; then
        TEST_TAG="$DOCKER_PROJECT:$DOCKER_IMAGE_TAG"
        CUR_TAG="$DOCKER_PROJECT:dev.$TRAVIS_BRANCH-$DOCKER_IMAGE_TAG"
        echo "Adding tag $TEST_TAG to the image for the testing"
        docker tag "$CUR_TAG" "$TEST_TAG"
        if [[ "$DOCKER_IMAGE_TAG" != "latest" ]]; then
            LATEST_TAG="$DOCKER_PROJECT:latest"
            echo "Adding latest tag $LATEST_TAG to the image for the testing"
            docker tag "$CUR_TAG" "$LATEST_TAG"
        fi
    fi
    prepare
    run_unit_tests
    run_integration_tests
}


main
