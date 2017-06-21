#!/bin/bash -ei
#
# -*- coding: utf-8 -*-
#
# This file is part of INSPIRE.
# Copyright (C) 2017 CERN.
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
#
# Note on the usage of signal handlers.
#
# In order to be able to restore the ownership of the venv at the end, we have
# to declare it as a trap for the EXIT signal, that forces us to not use
# 'exec' for the wrapped command, and that leads us to manually having to
# forward also the SIGTERM and SIGINT signals.
set -me

VENV_PATH=/virtualenv


restore_venv_rights() {
    if [[ "$BASE_USER_UID" != "" ]]; then
        BASE_USER_GID="${BASE_USER_GID:-$BASE_USER_UID}"
        echo "Restoring permissions of venv to $BASE_USER_UID:$BASE_USER_GID"
        /fix_rights --virtualenv "$BASE_USER_UID:$BASE_USER_GID"
        /fix_rights --codedir "$BASE_USER_UID:$BASE_USER_GID"
    else
        echo "No BASE_USER_UID env var defined, skipping venv permission" \
            "restore."
    fi
}

forward_sigterm() {
    echo "Forwarding SIGTERM to $child"
    kill -SIGTERM "$child" &>/dev/null
    trap forward_sigterm SIGTERM
    wait "$child"
}


forward_sigint() {
    echo "Forwarding SIGINT to $child"
    kill -SIGINT "$child" &>/dev/null
    trap forward_sigint SIGINT
    wait "$child"
}


prepare_venv() {
    virtualenv "$VENV_PATH" -p "python${INSPIRE_PYTHON_VERSION}"
    source "$VENV_PATH"/bin/activate
    pip install --upgrade pip
    pip install --upgrade setuptools wheel
    cp -r /src-cache "$VENV_PATH"/src
}


main() {
    /fix_rights --virtualenv 'test:test'
    /fix_rights --codedir 'test:test'
    trap restore_venv_rights EXIT

    if ! [[ -f "$VENV_PATH/bin/activate" ]]; then
        prepare_venv
    else
        source "$VENV_PATH"/bin/activate
    fi

    find \( -name __pycache__ -o -name '*.pyc' \) -delete

    trap forward_sigterm SIGTERM
    trap forward_sigint SIGINT

    "$@" &
    child="$!"
    fg >/dev/null
}


main "$@"
