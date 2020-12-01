#!/bin/bash
rm -rf ./builds
mkdir -p ./builds/dev
mkdir -p ./builds/beta
mkdir -p ./builds/prod

git checkout clients/aiv/main

mvn clean install -DskipTests -P aiv-devl-metadatacenter-geonetwork
mv ./web/target/geonetwork.war ./builds/dev/metadatacenter.war
mvn clean install -DskipTests -P aiv-beta-metadatacenter-geonetwork
mv ./web/target/geonetwork.war ./builds/beta/metadatacenter.war
mvn clean install -DskipTests -P aiv-prod-metadatacenter-geonetwork
mv ./web/target/geonetwork.war ./builds/prod/metadatacenter.war

mvn clean
git checkout clients/aiv/dcat-ap
git submodule init
git submodule update

mvn clean install -DskipTests -P aiv-devl-infocat-geonetwork
mv ./web/target/geonetwork.war ./builds/dev/ROOT.war
mvn clean install -DskipTests -P aiv-beta-infocat-geonetwork
mv ./web/target/geonetwork.war ./builds/beta/ROOT.war
mvn clean install -DskipTests -P aiv-prod-infocat-geonetwork
mv ./web/target/geonetwork.war ./builds/prod/ROOT.war
