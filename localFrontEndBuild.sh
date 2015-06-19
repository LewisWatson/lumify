#!/bin/bash
###############################################################################
## This is to be executed on your local machine and builds the web/war module
###############################################################################
MAVEN_WEB_PROFILES="web-war,web-war-with-gpw,web-war-with-ui-plugins"
MAVEN_ARGS="-X"
MAVEN_OPTS="-Xms1024m -Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError"

echo "MAVEN_OPTS = ${MAVEN_OPTS}"
echo "MAVEN_ARGS = ${MAVEN_ARGS}"
echo "MAVEN_GOALS = ${MAVEN_GOALS}"

export MAVEN_OPTS
mvn "${MAVEN_ARGS}" -P "${MAVEN_WEB_PROFILES}" -pl web/war -amd clean package install -DskipTests=true -Dsource.skip=true

