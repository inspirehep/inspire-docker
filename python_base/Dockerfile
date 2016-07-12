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
FROM centos

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum update -y
RUN yum install -y \
        ImageMagick \
        file \
        git \
        libffi-devel \
        libxml2-devel \
        libxslt-devel \
        nodejs \
        npm \
        poppler-utils \
        postgresql \
        postgresql-libs \
        python-pip \
        python-virtualenv \
        python-virtualenvwrapper \
        wget
RUN npm install -g npm
RUN npm install -g \
        node-sass \
        clean-css \
        requirejs \
        uglify-js

ARG INSPIRE_PYTHON_VERSION
ENV INSPIRE_PYTHON_VERSION ${INSPIRE_PYTHON_VERSION:-2.7}

RUN virtualenv /tmpvenv -p python${INSPIRE_PYTHON_VERSION} && \
    . /tmpvenv/bin/activate && \
    pip install --upgrade pip setuptools && \
    pip install --upgrade pip-accel requirements-builder && \
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
