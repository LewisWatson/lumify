#!/bin/bash
###############################################################################
## This is to be executed on the vagrant dev box and builds up-to the web/war 
## module
###############################################################################
MAVEN_ARGS="-X"
MAVEN_OPTS="-Xms1024m -Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError"

echo "MAVEN_OPTS = ${MAVEN_OPTS}"
echo "MAVEN_ARGS = ${MAVEN_ARGS}"
echo "MAVEN_GOALS = ${MAVEN_GOALS}"

export MAVEN_OPTS
mvn "${MAVEN_ARGS}" clean package -DskipTests=true

