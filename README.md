# inspire-docker
[![Build Status](https://travis-ci.org/inspirehep/inspire-docker.svg?branch=master "Build Status")](https://travis-ci.org/inspirehep/inspire-docker/branches?branch=master)

This repository is a submodule for [inspirehep/inspire-next](https://www.github.com/inspirehep/inspire-next) for keeping and building its docker files.

## Usage

Install Docker: https://docs.docker.com/engine/installation/

Then to grab current image and run tests from your development overlay:

```shell
cdvirtualenv src/inspire-next
docker pull inspirehep/inspire:next
docker run -v `pwd`:`pwd` inspirehep/inspire:next /bin/bash -c "cd `pwd` && ./install.sh && python setup.py test"
```

Then access the docker container interactively with a shell:

```shell
docker run -it -v `pwd`:`pwd` inspirehep/inspire:next /bin/bash
```
