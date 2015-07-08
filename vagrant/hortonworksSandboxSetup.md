You can install accumulo on the sandbox via yum :D `yum install accumulo`. Then configuring `accumulo-env.sh` as follows:

```shell
cat /usr/hdp/2.2.4.2-2/accumulo/conf/accumulo-env.sh 
#! /usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###
### Configure these environment variables to point to your local installations.
###
### The functional tests require conditional values, so keep this style:
###
### test -z "$JAVA_HOME" && export JAVA_HOME=/usr/lib/jvm/java
###
###
### Note that the -Xmx -Xms settings below require substantial free memory:
### you may want to use smaller values, especially when running everything
### on a single machine.
###
if [ -z "$HADOOP_HOME" ]
then
   test -z "$HADOOP_PREFIX"      && export HADOOP_PREFIX=/usr/hdp/2.2.4.2-2/hadoop
else
   HADOOP_PREFIX="$HADOOP_HOME"
   unset HADOOP_HOME
fi

# hadoop-1.2:
# test -z "$HADOOP_CONF_DIR"       && export HADOOP_CONF_DIR="$HADOOP_PREFIX/conf"
# hadoop-2.0:
test -z "$HADOOP_CONF_DIR"     && export HADOOP_CONF_DIR="$HADOOP_PREFIX/etc/hadoop"

test -z "$JAVA_HOME"             && export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk.x86_64
test -z "$ZOOKEEPER_HOME"        && export ZOOKEEPER_HOME=/usr/hdp/2.2.4.2-2/zookeeper
test -z "$ACCUMULO_LOG_DIR"      && export ACCUMULO_LOG_DIR=$ACCUMULO_HOME/logs
if [ -f ${ACCUMULO_CONF_DIR}/accumulo.policy ]
then
   POLICY="-Djava.security.manager -Djava.security.policy=${ACCUMULO_CONF_DIR}/accumulo.policy"
fi
test -z "$ACCUMULO_TSERVER_OPTS" && export ACCUMULO_TSERVER_OPTS="${POLICY} -Xmx384m -Xms384m "
test -z "$ACCUMULO_MASTER_OPTS"  && export ACCUMULO_MASTER_OPTS="${POLICY} -Xmx128m -Xms128m"
test -z "$ACCUMULO_MONITOR_OPTS" && export ACCUMULO_MONITOR_OPTS="${POLICY} -Xmx64m -Xms64m"
test -z "$ACCUMULO_GC_OPTS"      && export ACCUMULO_GC_OPTS="-Xmx64m -Xms64m"
test -z "$ACCUMULO_GENERAL_OPTS" && export ACCUMULO_GENERAL_OPTS="-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -Djava.net.preferIPv4Stack=true"
test -z "$ACCUMULO_OTHER_OPTS"   && export ACCUMULO_OTHER_OPTS="-Xmx128m -Xms64m"
# what do when the JVM runs out of heap memory
export ACCUMULO_KILL_CMD='kill -9 %p'

### Optionally look for hadoop and accumulo native libraries for your
### platform in additional directories. (Use DYLD_LIBRARY_PATH on Mac OS X.)
### May not be necessary for Hadoop 2.x or using an RPM that installs to
### the correct system library directory.
# export LD_LIBRARY_PATH=${HADOOP_PREFIX}/lib/native/${PLATFORM}:${LD_LIBRARY_PATH}

# Should the monitor bind to all network interfaces -- default: false
# export ACCUMULO_MONITOR_BIND_ALL="true"
```

I also ran `/usr/hdp/2.2.4.2-2/accumulo/bin/accumulo init --instance-name lumify --password password --clear-instance-name` since that's what [lumify accumulo_init.sh](https://github.com/LewisWatson/lumify/blob/master/vagrant/config/accumulo/accumulo_init.sh) does on line 28.

To run Accumulo I adapted [lumify accumulo_init.sh](https://github.com/LewisWatson/lumify/blob/master/vagrant/config/accumulo/accumulo_init.sh) to look like this:

```shell
cat accumulo-init.sh 
#!/bin/sh
#
# accumulo Accumulo Server
# chkconfig: 2345 82 22
# description: Accumulo Service

RUN_AS=root
HADOOP_USER=hdfs

start() {
    su -s /bin/bash $RUN_AS -c "echo $HOSTNAME > /usr/hdp/2.2.4.2-2/accumulo/conf/masters"
    su -s /bin/bash $RUN_AS -c "echo $HOSTNAME > /usr/hdp/2.2.4.2-2/accumulo/conf/slaves"
    su -s /bin/bash $RUN_AS -c "echo $HOSTNAME > /usr/hdp/2.2.4.2-2/accumulo/conf/tracers"
    su -s /bin/bash $RUN_AS -c "echo $HOSTNAME > /usr/hdp/2.2.4.2-2/accumulo/conf/gc"
    su -s /bin/bash $RUN_AS -c "echo $HOSTNAME > /usr/hdp/2.2.4.2-2/accumulo/conf/monitor"
    su -s /bin/bash $RUN_AS -c "mkdir -p /var/log/accumulo"

    if [ $(su -s /bin/bash $HADOOP_USER -c "/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -ls /user | grep accumulo | wc -l") == "0" ]; then
        echo "Creating accumulo user in hdfs"
        su -s /bin/bash $HADOOP_USER -c "/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -mkdir -p /user/accumulo"
        su -s /bin/bash $HADOOP_USER -c "/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -chown accumulo /user/accumulo"
    fi

    su -s /bin/bash $RUN_AS -c "/usr/hdp/2.2.4.2-2/accumulo/bin/start-all.sh"
}

stop() {
    su -s /bin/bash $RUN_AS -c "/usr/hdp/2.2.4.2-2/accumulo/bin/stop-all.sh"
}

restart() {
    stop
    sleep 3
    start
}

case "$1" in
    start)
        echo "Starting Accumulo..."
        start
        ;;
    stop)
        echo "Stopping Accumulo..."
        stop
        ;;
    restart)
        echo "Restarting Accumulo..."
        restart
        ;;
    *)
        echo "Usage: /etc/init.d/accumulo {start|stop|restart}" >&2
        exit 1
        ;;
esac
```

and ran (I had already attempted to start accumulo so I went for a restart)

```shell
./accumulo-init.sh restart
Restarting Accumulo...
Stopping accumulo services...
2015-06-26 08:43:15,567 [fs.VolumeManagerImpl] WARN : dfs.datanode.synconclose set to false in hdfs-site.xml: data loss is possible on hard system reset or power loss
Accumulo shut down cleanly
Utilities and unresponsive servers will shut down in 5 seconds (Ctrl-C to abort)
Stopping gc on sandbox.hortonworks.com
Stopping monitor on sandbox.hortonworks.com
Stopping tracer on sandbox.hortonworks.com
Stopping gc on sandbox.hortonworks.com
Stopping monitor on sandbox.hortonworks.com
Stopping tracer on sandbox.hortonworks.com
Stopping unresponsive tablet servers (if any)...
Stopping unresponsive tablet servers hard (if any)...
Cleaning tablet server entries from zookeeper
2015-06-26 08:43:39,188 [fs.VolumeManagerImpl] WARN : dfs.datanode.synconclose set to false in hdfs-site.xml: data loss is possible on hard system reset or power loss
Cleaning all server entries in ZooKeeper
2015-06-26 08:43:43,146 [fs.VolumeManagerImpl] WARN : dfs.datanode.synconclose set to false in hdfs-site.xml: data loss is possible on hard system reset or power loss
Starting monitor on sandbox.hortonworks.com
Starting tablet servers .... done
Starting tablet server on sandbox.hortonworks.com
2015-06-26 08:43:58,139 [fs.VolumeManagerImpl] WARN : dfs.datanode.synconclose set to false in hdfs-site.xml: data loss is possible on hard system reset or power loss
2015-06-26 08:43:58,160 [server.Accumulo] INFO : Attempting to talk to zookeeper
2015-06-26 08:43:58,438 [server.Accumulo] INFO : Zookeeper connected and initialized, attemping to talk to HDFS
2015-06-26 08:43:58,736 [server.Accumulo] INFO : Connected to HDFS
Starting master on sandbox.hortonworks.com
Starting garbage collector on sandbox.hortonworks.com
Starting tracer on sandbox.hortonworks.com
```

### Installing Elasticsearch

I adapted the lumify vagrant installation scripts for elastic search. Copy the contents of [lumify/vagrant/config/elasticsearch](https://github.com/LewisWatson/lumify/tree/master/vagrant/config/elasticsearch) into a directory called `elasticsearch` along with [install-elasticsearch.sh](https://github.com/LewisWatson/lumify/blob/master/vagrant/scripts/install-elasticsearch.sh).

note: remove the JAVA_HOME line from `elasticsearch_init.sh`

Then create and run `elasticsearch.sh`

```shell
# Install ElasticSearch
echo "Install ElasticSearch"
echo "export PATH=\$PATH:/opt/elasticsearch/bin" >> /etc/profile.d/elasticsearch.sh
source /etc/profile.d/elasticsearch.sh
/bin/bash elasticsearch/install-elasticsearch.sh
cp elasticsearch/elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml
cp elasticsearch/elasticsearch_init.sh /etc/init.d/elasticsearch
chmod +x /etc/init.d/elasticsearch
chkconfig --add elasticsearch
service elasticsearch start
```

### Installing RabbitMQ

I adapted the lumify vagrant installation scripts for RabbitMQ. Copy the contents of [lumify/vagrant/config/rabbitmq](https://github.com/LewisWatson/lumify/tree/master/vagrant/config/rabbitmq) into a directory called `rabbitmq` along with [install-rabbitmq.sh](https://github.com/LewisWatson/lumify/blob/master/vagrant/scripts/install-rabbitmq.sh).

note: remove the JAVA_HOME line from `rabbitmq_init.sh`

I had to install erlang `yum -y install erlang`.

Then create and run `rabbitmq.sh`

```shell
echo "Install RabbitMQ"
echo "export PATH=\$PATH:/opt/rabbitmq/sbin" >> /etc/profile.d/rabbitmq.sh
source /etc/profile.d/rabbitmq.sh
/bin/bash rabbitmq/install-rabbitmq.sh
cp rabbitmq/etc/rabbitmq/rabbitmq.config /opt/rabbitmq_server-3.4.1/etc/rabbitmq/rabbitmq.config
cp rabbitmq/rabbitmq_init.sh /etc/init.d/rabbitmq
chmod +x /etc/init.d/rabbitmq
chkconfig --add rabbitmq
service rabbitmq start
```

### Installing Jetty

I adapted the lumify vagrant installation scripts for Jetty. Copy the contents of [lumify/vagrant/config/jetty](https://github.com/LewisWatson/lumify/tree/master/vagrant/config/jetty) into a directory called `jetty` along with [install-jetty.sh](https://github.com/LewisWatson/lumify/blob/master/vagrant/scripts/install-jetty.sh).

note: remove the JAVA_HOME line as well as `export PATH=$PATH:/opt/jdk/bin` from `jetty_init.sh`

Then create and run `jetty.sh`

```shell
echo "Install Jetty"
echo "export PATH=\$PATH:/opt/jetty/bin" >> /etc/profile.d/jetty.sh
echo "export JETTY_HOME=/opt/jetty" >> /etc/profile.d/jetty.sh
source /etc/profile.d/jetty.sh
/bin/bash jetty/install-jetty.sh
cp jetty/start.ini /opt/jetty/start.ini
cp jetty/jetty-logging.properties /opt/jetty/resources/jetty-logging.properties
cp jetty/jetty.xml /opt/jetty/etc/jetty.xml
cp jetty/jetty-http.xml /opt/jetty/etc/jetty-http.xml
cp jetty/jetty-https.xml /opt/jetty/etc/jetty-https.xml
cp jetty/jetty-ssl.xml /opt/jetty/etc/jetty-ssl.xml
cp jetty/jetty.jks /opt/jetty/etc/jetty.jks
cp jetty/jetty_init.sh /etc/init.d/jetty
chmod +x /etc/init.d/jetty
```

### Lumify RPM dependencies

#### Add yum repositories

1. Copy [lumify/vagrant/vagrant/config/yum-repos/elasticsearch.repo](https://github.com/LewisWatson/lumify/blob/master/vagrant/config/yum-repos/elasticsearch.repo) to `/etc/yum.repos.d/elasticsearch.repo`

2. Copy [lumify/vagrant/vagrant/config/yum-repos/lumify.repo](https://github.com/LewisWatson/lumify/blob/master/vagrant/config/yum-repos/lumify.repo) to `/etc/yum.repos.d/lumify.repo`

#### Install RPM Dependancies

Create and run `install-npm-packages.sh`

```shell
#!/bin/bash -u

rpm -Uhv http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y --exclude apr-util,httpd update

#system tools
yum install -y wget curl tar sudo openssh-server openssh-clients git nodejs npm libuuid-devel libtool zip unzip rsync which erlang cmake bison

#ffmpeg
yum install -y lumify-videolan-x264 lumify-fdk-aac lumify-lame lumify-opus lumify-ogg lumify-vorbis lumify-vpx lumify-theora lumify-ffmpeg

#tesseract
yum install -y lumify-leptonica lumify-tesseract lumify-tesseract-eng

#CCExtractor
yum install -y lumify-ccextractor

#OpenCV
yum install -y lumify-opencv

#CMU Sphinx
yum install -y lumify-sphinxbase lumify-pocketsphinx
```
based on [/lumify/vagrant/scripts/install-npm-packages.sh](https://github.com/LewisWatson/lumify/blob/master/vagrant/scripts/install-npm-packages.sh).

#### Turn iptables firewall off

```shell
/etc/init.d/iptables stop
/sbin/chkconfig iptables off
```

#### Configure Lumify directories in HDFS

Adapted from `configure Lumify directories in HDFS` section of [install-lumify-dependencies.sh](https://github.com/LewisWatson/lumify/blob/master/vagrant/scripts/install-lumify-dependencies.sh))

Copy the following files into a directory called `config`:

 * [/lumify/config/opencv/*](https://github.com/LewisWatson/lumify/blob/master/config/opencv)
 * [lumify/config/opennlp/*](https://github.com/LewisWatson/lumify/tree/master/config/opennlp)
 * [/vagrant/config/knownEntities/dictionaries/*](https://github.com/LewisWatson/lumify/tree/master/config/knownEntities/dictionaries)

Then run

```shell
/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -mkdir -p /lumify/libcache
/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -mkdir -p /lumify/config/opencv
/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -mkdir -p /lumify/config/opennlp
/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -mkdir -p /lumify/config/knownEntities/dictionaries
/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -put config/opencv/haarcascade_frontalface_alt.xml /lumify/config/opencv/
/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -put config/opennlp/* /lumify/config/opennlp/
/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -put config/knownEntities/dictionaries/* /lumify/config/knownEntities/dictionaries/
/usr/hdp/2.2.4.2-2/hadoop/bin/hadoop fs -chmod -R a+w /lumify/
```