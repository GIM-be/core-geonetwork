#!/usr/bin/env bash
# Install transifex client first.
# sudo apt-get install transifex-client
# on OSX run pip if you have that installed
# sudo pip install transifex-client

if hash tx 2>/dev/null; then
  if [ ! -d "transifex-src" ]; then
    echo Init transifex project
    mkdir transifex-src
    cd transifex-src
    tx init --host=www.transifex.com --force --no-interactive
    tx set --auto-remote https://www.transifex.com/projects/p/core-geonetwork/
    cd ..
  fi

  cd transifex-src
  tx pull -r 'core-geonetwork.editor' -l nl_BE
  tx pull -r 'core-geonetwork.admin' -l nl_BE
  tx pull -r 'core-geonetwork.core' -l nl_BE
  tx pull -r 'core-geonetwork.search' -l nl_BE
  cd ..

  TRANSLATION_DIR=transifex-src/translations/core-geonetwork.
  SRC_DIR=src/main/resources/catalog/locales

  l=(
      'nl::nl_BE'
  )

  for index in "${l[@]}" ; do
      KEY="${index%%::*}"
      VALUE="${index##*::}"
    echo "Language $VALUE"
    for mod in admin core editor search
    do
      cp $TRANSLATION_DIR$mod/$VALUE.json $SRC_DIR/$KEY-$mod.json
    done;
  done
else
  echo [WARNING]: Translations cannot be updated. Install Transifex CLI and re-execute maven build.
fi
