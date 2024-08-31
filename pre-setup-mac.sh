#!/usr/bin/env bash

xcode-select --install
yes | pip install pipx
pipx install --include-deps ansible
