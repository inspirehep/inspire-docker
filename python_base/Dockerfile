# -*- coding: utf-8 -*-
#
# This file is part of INSPIRE.
# Copyright (C) 2016, 2017 CERN.
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
FROM centos:7.4.1708

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum update -y && \
    yum install -y \
        ImageMagick \
        transfig \
        file \
        firefox \
        gcc \
        gcc-c++ \
        git \
        libffi-devel \
        libxml2-devel \
        libxslt-devel \
        mailcap \
        make \
        nodejs \
        npm \
        openssl-devel \
        poppler-utils \
        postgresql \
        postgresql-libs \
        postgresql-devel \
        python-pip \
        python-virtualenv \
        xrootd-python \
        wget \
        Xvfb \
        && \
    yum clean all
RUN npm install -g \
        node-sass@3.8.0 \
        clean-css@^3.4.24 \
        requirejs \
        uglify-js

RUN mkdir /code /deps /tmpvenv /src-cache /pip-cache


ARG INSPIRE_PYTHON_VERSION
ENV INSPIRE_PYTHON_VERSION ${INSPIRE_PYTHON_VERSION:-2.7}

RUN virtualenv -v /tmpvenv -p python${INSPIRE_PYTHON_VERSION} && \
    . /tmpvenv/bin/activate && \
    pip install -q --upgrade pip && \
    pip install -q --upgrade setuptools wheel && \
    pip install -q --upgrade requirements-builder && \
    pip install -q --upgrade poetry==1.0.0 && \
    cd /tmp && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/pyproject.toml && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/poetry.lock && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/setup.py && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/README.rst && \
    mkdir inspirehep/ && \
    cd inspirehep/ && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/inspirehep/version.py && \
    cd /tmp && \
    poetry export --no-ansi --without-hashes -E all -E xrootd -f requirements.txt > requirements.poetry.txt && \
    pip install -qqq --requirement requirements.poetry.txt && \
    pip freeze > /deps/deps.txt && \
    deactivate && \
    mv /tmpvenv/src /src-cache && \
    rm -rf /tmpvenv && \
    dbus-uuidgen > /etc/machine-id


RUN useradd test
RUN chown -R test:test /code /deps /src-cache /pip-cache
# This allows us to change the venv rights after it has been created
ADD ./python_base/docker_entrypoint.sh /docker_entrypoint.sh
ADD ./python_base/fix_rights /fix_rights
RUN chmod 4755 /fix_rights

USER test
WORKDIR /code
ENTRYPOINT ["/docker_entrypoint.sh"]
CMD true
