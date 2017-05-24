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

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum update -y && \
    yum install -y \
        ImageMagick \
        file \
        firefox \
        gcc \
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
        wget && \
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
    pip install --upgrade pip && \
    pip install --upgrade setuptools wheel && \
    pip install --upgrade requirements-builder && \
    cd /tmp && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/requirements.txt && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/setup.py && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/README.rst && \
    mkdir inspirehep/ && \
    cd inspirehep/ && \
    wget -q https://raw.githubusercontent.com/inspirehep/inspire-next/master/inspirehep/version.py && \
    cd /tmp && \
    egrep -v '^-e \.\[[a-z]+\]$' requirements.txt >> requirements-all.txt && \
    requirements-builder setup.py -e all -e postgresql >> requirements-all.txt && \
    pip wheel --wheel-dir /pip-cache -r requirements-all.txt --pre && \
    pip install --find-links /pip-cache -r requirements.txt --pre -e .[tests,crawler,docs] gunicorn --exists-action i && \
    pip uninstall -y Inspirehep && \
    pip freeze > /deps/deps.txt && \
    deactivate && \
    mv /tmpvenv/src /src-cache && \
    rm -rf /tmpvenv && \
    dbus-uuidgen > /etc/machine-id


RUN useradd test
RUN chown -R test:test /code /deps /src-cache /pip-cache
# This allows us to change the venv rights after it has been created
ADD ./python_base/docker_entrypoint.sh /docker_entrypoint.sh
ADD ./python_base/fix_venv_rights /fix_venv_rights
RUN chmod 4755 /fix_venv_rights

USER test
WORKDIR /code
ENTRYPOINT ["/docker_entrypoint.sh"]
CMD true
