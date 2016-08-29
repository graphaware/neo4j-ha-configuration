#!/bin/bash

INSTALL_DIR=~/neo4j-ha/$1

#Create install directory
mkdir -p $INSTALL_DIR

pushd $INSTALL_DIR

#Download neo4j
wget -O neo4j.tar.gz "http://neo4j.com/artifact.php?name=neo4j-enterprise-$1-unix.tar.gz"

#Unpack
tar -xzf neo4j.tar.gz

#Create directory
mv neo4j-enterprise-$1 neo4j-1

#Copy
cp -r neo4j-1 neo4j-2
cp -r neo4j-1 neo4j-3
cp -r neo4j-1 neo4j-arbiter

#Delete archive
rm neo4j.tar.gz

#Create start script
echo "./neo4j-1/bin/neo4j start && ./neo4j-2/bin/neo4j start && ./neo4j-3/bin/neo4j start && ./neo4j-arbiter/bin/neo4j-arbiter start" > $INSTALL_DIR/start-cluster.sh

#Create stop script
echo "./neo4j-1/bin/neo4j stop && ./neo4j-2/bin/neo4j stop && ./neo4j-3/bin/neo4j stop && ./neo4j-arbiter/bin/neo4j-arbiter stop" > $INSTALL_DIR/stop-cluster.sh

chmod +x *.sh

popd

#Copy config
cp neo4j-1/* $INSTALL_DIR/neo4j-1/conf
cp neo4j-2/* $INSTALL_DIR/neo4j-2/conf
cp neo4j-3/* $INSTALL_DIR/neo4j-3/conf
cp neo4j-arbiter/* $INSTALL_DIR/neo4j-arbiter/conf


