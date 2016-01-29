# inspire-docker
[![Build Status](https://travis-ci.org/inspirehep/inspire-docker.svg?branch=master "Build Status")](https://travis-ci.org/inspirehep/inspire-docker/branches?branch=master)

This repository is a submodule for [inspirehep/inspire-next](https://www.github.com/inspirehep/inspire-next) for keeping and building its docker files.

If you want to test INSPIRE in the same way as it is tested in Travis you can simply:
```
$ cd <source directory of inspirehep repo>
$ docker pull inspirehep/inspire:next
$ docker run -v `pwd`:`pwd` inspirehep/inspire:next /bin/bash -c "cd `pwd` && ./install.sh && python setup.py test"
```
