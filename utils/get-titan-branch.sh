#!/bin/bash

TITAN_BRANCH=$1

if [ -z "$TITAN_BRANCH" -o "$TITAN_BRANCH" == "" ]; then
  TITAN_BRANCH="master"
fi

echo $TITAN_BRANCH
