#!/bin/bash

[ -d /tmp/media/bigbigpuppetfacts ] || \
	( bbpfcodedir=$PWD/../`basename $PWD ` ; \
		mkdir -p /tmp/media ;  \
		cd  /tmp/media ; \
		git clone $bbpfcodedir    ; \
		cd `basename $bbpfcodedir ` ; \
		git reset --hard ; \
		git checkout 4publicversion ; \
	)

CLIDIR=$PWD
cd /tmp/media/bigbigpuppetfacts

CLIDIR=$CLIDIR  $0 $@