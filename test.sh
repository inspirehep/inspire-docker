#!/bin/bash -e
REQUIRED_VARS=(
    TRAVIS_BRANCH
    DOCKER_PROJECT
    DOCKER_IMAGE_TAG
)
INSTALL_COMPOSE=true
REDOWNLOAD_NEXT=true
BASE_DIR="$(cd "${0%%/*}"; pwd)"
NEXT_DIR="$BASE_DIR/inspire-next"
VENV_DIR="${DOCKER_DATA}/tmp/virtualenv"


help(){
    cat <<EOH
    Usage: $0 [options]

    Options:
        -h|--help
            Show this help

        -v|--verbose
            Enable verbose mode

        -n|--no-install-compose
            Do not install docker-compose on the system, useful for local runs

        -u|--use-existing-next
            If already exists, use the inspire-next repo instead of removin it
            and redownloading it. The repo that will be used must be at
            $NEXT_DIR

    Required environment variables:
        $(for var in "${REQUIRED_VARS[@]}"; do echo -ne "$var\n        "; done)

EOH
    exit "${1:-0}"
}


retry() {
    if ! "$@"; then
        echo "******** Retrying $*"
        "$@" || exit $?
    fi
}


utils.in(){
    local what="$1"
    shift
    local where=("$@")
    for key in "${where[@]}"; do
        [[ "$what" == "$key" ]] && return 0
    done
    return 1
}


get_images(){
    grep -ohP "(?<=image: ).*" "$NEXT_DIR/"*.yml | sort | uniq
}


install_docker_compose(){
    retry sudo pip install docker-compose
    # Add docker-compose at the version specified in ENV.
    sudo rm -f /usr/local/bin/docker-compose
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" > docker-compose
    chmod +x docker-compose
    sudo mv docker-compose /usr/local/bin
    export PATH=$PATH:/usr/local/bin
}


clone_next(){
    rm -rf "$NEXT_DIR"
    git clone https://github.com/inspirehep/inspire-next.git "$NEXT_DIR"
    # TODO remove once it's merged
    git fetch origin refs/pull/2124
    git reset --hard FETCH_HEAD
}


prepare() {
    if ! [[ -e "$NEXT_DIR" ]] || $REDOWNLOAD_NEXT; then
        clone_next
    fi
    if $INSTALL_COMPOSE; then
        install_docker_compose
    fi
}


cleanup_env() {
    cd "$NEXT_DIR"
    docker-compose kill
    docker-compose rm -f
    sudo rm -rf "$VENV_DIR"
    cd -
}


pull_all_images_except(){
    local to_skip=("$@")
    local images=($(get_images))
    local image
    echo "##### Pulling the docker images"
    cd "$NEXT_DIR"
    for image in "${images[@]}"; do
        utils.in "$image" "${to_skip[@]}" && continue
        retry docker pull "$image"
    done
    echo "#################"
}


run_unit_tests() {
    cd "$NEXT_DIR"
    echo "###### Running unit tests"
    cleanup_env
    echo "--- Available images"
    docker images
    echo "----------------"
    retry docker-compose -f docker-compose.deps.yml run --rm pip
    docker-compose -f docker-compose.deps.yml run --rm assets
    docker-compose -f docker-compose.test.yml run --rm unit
    cleanup_env
    echo "#################"
}


run_integration_tests() {
    cd "$NEXT_DIR"
    echo "###### Running integraiton tests"
    cleanup_env
    echo "--- Available images"
    docker images
    echo "----------------"
    retry docker-compose -f docker-compose.deps.yml run --rm pip
    docker-compose -f docker-compose.deps.yml run --rm assets
    docker-compose -f docker-compose.test.yml run --rm integration
    cleanup_env
    echo "#################"
}


parse_options(){
    local opts
    opts=$(\
        getopt \
            --options 'hnuv' \
            --longoptions 'help,no-install-compose,use-existing-next,verbose' \
            --name "$0" \
            -- "$@" \
    ) ||  help 1
    local failed=false
    local env_var
    eval set -- "$opts"
    while true; do
        opt="$1"
        shift;
        case $opt in
            -n|--no-install-compose)
                INSTALL_COMPOSE=false;;
            -u|--use-existing-next)
                REDOWNLOAD_NEXT=false;;
            -h|--help) help 0;;
            -v|--verbose) set -x;;
            --) break;;
        esac
    done
    for env_var in "${REQUIRED_VARS[@]}"; do
        [[ -v $env_var ]] || {
            echo "Undefined var $env_var, please define befor running this" \
                "script"
            failed=true
        }
    done
    if $failed; then
        echo -e "Some required env vars were not defined, aborting\n"
        help 1
    fi
}


main() {
    parse_options "$@"
    if [[ "$TRAVIS_BRANCH" != "master" ]]; then
        TEST_TAG="$DOCKER_PROJECT:$DOCKER_IMAGE_TAG"
        CUR_TAG="$DOCKER_PROJECT:dev.$TRAVIS_BRANCH-$DOCKER_IMAGE_TAG"
        echo "Adding tag $TEST_TAG to the image for the testing"
        docker tag "$CUR_TAG" "$TEST_TAG"
    else
        CUR_TAG="$DOCKER_PROJECT:$DOCKER_IMAGE_TAG"
    fi
    if [[ "$DOCKER_IMAGE_TAG" != "latest" ]]; then
        LATEST_TAG="$DOCKER_PROJECT:latest"
        echo "Adding latest tag $LATEST_TAG to the image for the testing"
        docker tag "$CUR_TAG" "$LATEST_TAG"
    fi
    prepare
    pull_all_images_except "$DOCKER_PROJECT"
    run_unit_tests
    run_integration_tests
    echo "==================  SUCCESS"
}


main "$@"
