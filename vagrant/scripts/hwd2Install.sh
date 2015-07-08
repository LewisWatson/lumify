#!/bin/bash -eu

# http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.1.1/bk_installing_manually_book/content/rpm-chap2-3.html

wget -nv http://public-repo-1.hortonworks.com/HDP/centos6/2.x/GA/2.1-latest/hdp.repo -O /etc/yum.repos.d/hdp.repo 

echo "Installing NTP"
yum -y install ntp
chkconfig ntpd on
/etc/init.d/ntpd start

echo "Setting environmental variables"
cat /vagrant/vagrant/scripts/hw/scripts/directories.sh >> ~/.bash_profile
cat /vagrant/vagrant/scripts/hw/scripts/usersAndGroups.sh >> ~/.bash_profile
source ~/.bash_profile

echo $DFS_NAME_DIR;

echo "HDP Memory Configuration Settings"
python /vagrant/vagrant/scripts/hw/scripts/hdp-configuration-utils.py -c 4 -m 3 -d 1 -k True

echo "Install the Hadoop Packages"
yum -y install hadoop hadoop-hdfs hadoop-libhdfs hadoop-yarn hadoop-mapreduce hadoop-client openssl

echo "Installing Compression"
yum -y install snappy snappy-devel lzo lzo-devel hadoop-lzo hadoop-lzo-native

echo "Create the NameNode Directories"
sudo mkdir -p $DFS_NAME_DIR;
sudo chown -R $HDFS_USER:$HADOOP_GROUP $DFS_NAME_DIR;
sudo chmod -R 755 $DFS_NAME_DIR;

echo "Create the SecondaryNameNode Directories"
sudo mkdir -p $FS_CHECKPOINT_DIR;
sudo chown -R $HDFS_USER:$HADOOP_GROUP $FS_CHECKPOINT_DIR;
sudo chmod -R 755 $FS_CHECKPOINT_DIR;

echo "Create DataNode and YARN NodeManager Local Directories"
sudo mkdir -p $DFS_DATA_DIR;
sudo chown -R $HDFS_USER:$HADOOP_GROUP $DFS_DATA_DIR;
sudo chmod -R 750 $DFS_DATA_DIR;

sudo mkdir -p $YARN_LOCAL_DIR;
sudo chown -R $YARN_USER:$HADOOP_GROUP $YARN_LOCAL_DIR;
sudo chmod -R 755 $YARN_LOCAL_DIR;

sudo mkdir -p $YARN_LOCAL_LOG_DIR;
sudo chown -R $YARN_USER:$HADOOP_GROUP $YARN_LOCAL_LOG_DIR;
sudo chmod -R 755 $YARN_LOCAL_LOG_DIR;

echo "Create the Log and PID Directories"
sudo mkdir -p $HDFS_LOG_DIR;
sudo chown -R $HDFS_USER:$HADOOP_GROUP $HDFS_LOG_DIR;
sudo chmod -R 755 $HDFS_LOG_DIR;

sudo mkdir -p $YARN_LOG_DIR;
sudo chown -R $YARN_USER:$HADOOP_GROUP $YARN_LOG_DIR;
sudo chmod -R 755 $YARN_LOG_DIR;

sudo mkdir -p $HDFS_PID_DIR;
sudo chown -R $HDFS_USER:$HADOOP_GROUP $HDFS_PID_DIR;
sudo chmod -R 755 $HDFS_PID_DIR

sudo mkdir -p $YARN_PID_DIR;
sudo chown -R $YARN_USER:$HADOOP_GROUP $YARN_PID_DIR;
sudo chmod -R 755 $YARN_PID_DIR;

sudo mkdir -p $MAPRED_LOG_DIR;
sudo chown -R $MAPRED_USER:$HADOOP_GROUP $MAPRED_LOG_DIR;
sudo chmod -R 755 $MAPRED_LOG_DIR;

sudo mkdir -p $MAPRED_PID_DIR;
sudo chown -R $MAPRED_USER:$HADOOP_GROUP $MAPRED_PID_DIR;
sudo chmod -R 755 $MAPRED_PID_DIR;