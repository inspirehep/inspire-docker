# -*- coding: utf-8 -*-
#
# This file is part of INSPIRE.
# Copyright (C) 2016 CERN.
#
# INSPIRE is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# INSPIRE is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with INSPIRE. If not, see <http://www.gnu.org/licenses/>.
#
# In applying this licence, CERN does not waive the privileges and immunities
# granted to it by virtue of its status as an Intergovernmental Organization
# or submit itself to any jurisdiction.
FROM python:3.5

RUN apt-get update --fix-missing && \
    apt-get install -y \
      python-virtualenv \
      python-dev \
      git \
      nodejs \
      npm \
      libpq-dev \
      build-essential \
      libxml2-dev \
      libxslt1-dev \
      libjpeg-dev \
      libfreetype6-dev \
      libtiff-dev \
      libmagickwand-dev \
      imagemagick \
      ghostscript \
      xpdf \
      libffi-dev \
      liblzma-dev && \
    ln -s /usr/bin/nodejs /usr/bin/node && \
    npm install -g \
      npm \
      node-sass \
      clean-css \
      requirejs \
      uglify-js

ARG INSPIRE_PYTHON_VERSION
ENV INSPIRE_PYTHON_VERSION ${INSPIRE_PYTHON_VERSION:-2.7}

RUN virtualenv /tmpvenv -p python${INSPIRE_PYTHON_VERSION} && \
    . /tmpvenv/bin/activate && \
    pip install --upgrade setuptools pip-accel requirements-builder && \
    cd /tmp && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/requirements.txt && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/setup.py && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/README.rst && \
    mkdir inspirehep/ && cd inspirehep/ && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/inspirehep/version.py && cd /tmp && \
    egrep -v '^-e \.\[[a-z]+\]$' requirements.txt >> requirements-all.txt && \
    requirements-builder setup.py -e all >> requirements-all.txt && \
    pip-accel install -r requirements-all.txt --pre && \
    deactivate && \
    rm -rf /tmpvenv && \
    mkdir /code

WORKDIR /code

ADD ./python_base/docker_entrypoint.sh /docker_entrypoint.sh
ENTRYPOINT ["/docker_entrypoint.sh"]
CMD true
