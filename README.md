# inspire-docker
[![Build Status](https://travis-ci.org/inspirehep/inspire-docker.svg?branch=master "Build Status")](https://travis-ci.org/inspirehep/inspire-docker/branches?branch=master)

## Usage

Install Docker: https://docs.docker.com/engine/installation/

To grab a Python image having (almost) all the dependencies cached for `pip-accel`
In which you can install the overlay:

```shell
docker pull inspirehep/python_base:latest
```

If you want a specific Python version you can do:
```shell
docker pull inspirehep/python_base:python2.7
```

Python 3.5 is still not compatible.

To grab an Elasticsearch image having all the plugins needed for running
the Overlay do:

```shell
docker pull inspirehep/elasticsearch:latest
```
