#!/usr/bin/env bash
# Install transifex client first.
# sudo apt-get install transifex-client
# on OSX run pip if you have that installed
# sudo pip install transifex-client

mkdir transifex-src
cd transifex-src
tx init --host=www.transifex.com
tx set --auto-remote https://www.transifex.com/projects/p/core-geonetwork/


