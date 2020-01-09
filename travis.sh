#!/bin/bash -ev

conf_python_base_versioned() {
    export DOCKER_PROJECT=inspirehep/python-base
    export DOCKER_IMAGE_TAG=2.7
    export DOCKERFILE=python_base/Dockerfile
    export ARGS='--build-arg=INSPIRE_PYTHON_VERSION=2.7'
}

conf_python_base_latest() {
    export DOCKER_PROJECT=inspirehep/python-base
    export DOCKER_IMAGE_TAG=latest
    export DOCKERFILE=python_base/Dockerfile
    export ARGS='--build-arg=INSPIRE_PYTHON_VERSION=2.7'
}


conf_python_base_test_versioned() {
    export DOCKER_PROJECT=inspirehep/python-base-test
    export DOCKER_IMAGE_TAG=2.7
    export DOCKERFILE=python_base_test/Dockerfile
    export ARGS='--build-arg=INSPIRE_PYTHON_VERSION=2.7'
}

conf_python_base_test_latest() {
    export DOCKER_PROJECT=inspirehep/python-base-test
    export DOCKER_IMAGE_TAG=latest
    export DOCKERFILE=python_base_test/Dockerfile
    export ARGS='--build-arg=INSPIRE_PYTHON_VERSION=2.7'
}

conf_elasticsearch() {
    export DOCKER_PROJECT=inspirehep/elasticsearch
    export DOCKER_IMAGE_TAG=latest
    export DOCKERFILE=elasticsearch/Dockerfile
    export ARGS=''
}

conf_elasticsearch5() {
    export DOCKER_PROJECT=inspirehep/elasticsearch5
    export DOCKER_IMAGE_TAG=latest
    export DOCKERFILE=elasticsearch5/Dockerfile
    export ARGS=''
}

conf_elasticsearch7() {
    export DOCKER_PROJECT=inspirehep/elasticsearch7
    export DOCKER_IMAGE_TAG=latest
    export DOCKERFILE=elasticsearch7/Dockerfile
    export ARGS=''
}

conf_elasticsearch; ./build.sh
conf_elasticsearch5; ./build.sh
conf_elasticsearch7; ./build.sh
conf_python_base_versioned; ./build.sh
conf_python_base_latest; ./build.sh
conf_python_base_test_versioned; ./build.sh
conf_python_base_test_latest; ./build.sh

./test.sh

conf_elasticsearch; ./deploy.sh
conf_elasticsearch5; ./deploy.sh
conf_elasticsearch7; ./deploy.sh
conf_python_base_versioned; ./deploy.sh
conf_python_base_latest; ./deploy.sh
conf_python_base_test_versioned; ./deploy.sh
conf_python_base_test_latest; ./deploy.sh
