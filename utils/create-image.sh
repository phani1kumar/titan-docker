#!/bin/bash

display_usage() {
  echo -e "\nUsage: $0 [-t TITAN-VERSION] [-b TITAN-BRANCH] [-c CASSANDRA-VERSION] [-e ELASTICSEARCH-VERSION]\n"
}

while getopts ":t:c:e:b:" opt; do
  case $opt in
    t)
      TITAN_VERSION=$OPTARG
      ;;
    c)
      CASSANDRA_VERSION=$OPTARG
      ;;
    e)
      ELASTICSEARCH_VERSION=$OPTARG
      ;;
    b)
      TITAN_BRANCH=$OPTARG
      ;;
    \?)
      display_usage
      exit 1
      ;;
    :)
      display_usage
      exit 1
      ;;
  esac
done

PWD=`pwd`
DIR=$(dirname `readlink -f $0`)

cd $DIR

TITAN_VERSION=`./get-titan-version.sh $TITAN_VERSION`
TITAN_BRANCH=`./get-titan-branch.sh $TITAN_BRANCH`

if [ -z $CASSANDRA_VERSION ]; then
  CASSANDRA_VERSION=`./get-cassandra-version.sh $TITAN_VERSION`
fi

if [ -z $ELASTICSEARCH_VERSION ]; then
  ELASTICSEARCH_VERSION=`./get-elasticsearch-version.sh $TITAN_VERSION`
fi

cd ..
sed -e "s/CASSANDRA_VERSION/$CASSANDRA_VERSION/g" -e "s/TITAN_VERSION/$TITAN_VERSION/g" -e "s/TITAN_BRANCH/$TITAN_BRANCH/g" templates/Dockerfile.tpl > Dockerfile
cp templates/gremlin.sh.tpl scripts/gremlin.sh

if [ "$TITAN_VERSION" != "`echo -e "$TITAN_VERSION\n0.5.0" | sort -rV | head -n1`" ]; then
  sed -i '/hadoop/d' Dockerfile scripts/gremlin.sh
fi

if [ "$TITAN_VERSION" == "0.5.0-M1" -o "$TITAN_VERSION" == "0.5.0-M2" ]; then
  sed -i '/hadoop/d' Dockerfile scripts/gremlin.sh
fi

if [ -z $ELASTICSEARCH_VERSION ]; then
  sed -i '/elasticsearch/d' Dockerfile scripts/gremlin.sh
else
  sed -i "s/ELASTICSEARCH_VERSION/$ELASTICSEARCH_VERSION/g" Dockerfile
fi


cd $PWD
