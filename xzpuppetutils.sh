#!/bin/bash



SUDOCMD='sudo -E'
FACTERCMD='/opt/puppetlabs/bin/facter'
PUPPETCMD='/opt/puppetlabs/bin/puppet'

rubycmd="/opt/puppetlabs/puppet/bin/ruby -I../lib -I /opt/puppetlabs/puppet/cache/lib"
taskfile='./ensure_mssql_user.rb'
taskname='scb_mssql_ura::ensure_mssql_user'

if [ "$MSYSTEM" = 'MINGW64' ]  ; then
    export PATH="$PATH:/c/Program Files/Puppet Labs/Puppet/puppet/bin"
	rubycmd="ruby.exe   -I../lib -I /c/ProgramData/PuppetLabs/puppet/cache/lib"
	SUDOCMD=''
	FACTERCMD='"C:\\Program Files\\Puppet Labs\\Puppet\\bin\\facter.bat"'
	PUPPETCMD='"C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet.bat"'
fi;

JQCMD=" jq  "
which jq 2>&1  > /dev/null ||  JQCMD=" `dirname $0`/settestrunner.sh ctshowjson  "

### test path2sampleFile  maxsizetoconsider_in_k sizeincstep_in_k rptpath
## e.g.    $0   test  /tmp/mongodb_instances-info

######## Simple Test to check the performance

function perftest(){

   sudo /opt/puppetlabs/bin/facter -p mongodb_instances-info -j  > /tmp/mongodb_instances-info.json  ;

    # $0  test  <SAMPLEFILE TO DRAFT THE CONTENT>    <MAXFILESIZE>  <INCFILESIZE/STARTFILESIZE>      <REPORT_PATH>

    $0   test /tmp/mongodb_instances-info.json     512   2   /tmp/smallsizejsontest.csv    ## Simple test on Jsonfile on smallsize.  2k to 512k
    $0   test /tmp/mongodb_instances-info.json    102400   1024   /tmp/bigsizejsontest.csv    ## Simple test on Jsonfile on bigsize. 1024k(1M) to 102400k(100M)

     file  `which xz`
    $0   test  `which xz`     512   2     /tmp/smallsizebinarytest.csv  ## Simple test on ELF aka Binary on smallsize.  2k to 512k
    $0   test  `which xz`   102400   1024     /tmp/bigsizebinarytest.csv   ## Simple test on ELF aka Binary  on bigsize. 1024k(1M) to 102400k(100M)
     file  `which xz`

}

if [   "$1" = 'perftest'    ] ; then
    perftest
elif [[   "$1" = 'test'     ]] ; then
    path2sampleFile=${2:-/dev/zero}
    maxsizetoconsider=${3:-10240 }  # 10MB
    sizeincstep=${4:-2 }         # 2k
    rptpath=${5:-/tmp/report.csv }

    testfile=/tmp/perftest_testfile
    testsrc=/tmp/perftest_unit.txt
    testsrcinc=/tmp/perftest_unitinc.txt
    testdone=/tmp/perftest_compressfile.txt

    methodused=compress_xz_base64

    ##prep
    echo  Prep Start...
    touch $testfile
    while [  `stat -c%s $testfile`  -lt  0$maxsizetoconsider   ] ; do
        cat $path2sampleFile >>  $testfile
    done

    touch $testsrcinc
    if [  `stat -c%s $testsrcinc`  -gt  0$sizeincstep   ] ; then
        > $testsrcinc
    fi;
    while [  `stat -c%s $testsrcinc`  -lt  0$sizeincstep   ] ; do
        dd if=$testfile    of=$testsrcinc   count=$sizeincstep  ibs=1k  oflag=sync
    done
    > $testsrc
    > $testdone
    echo  Prep Done...
    echo  Test Start...
    echo 'originalsize(B),compressmethod,compressratio_in_percent,compressedsize(B),timetaken_in_sec'  >  $rptpath
    sizetouse=$sizeincstep
    while [ $sizetouse    -lt  0$maxsizetoconsider   ] ; do

        cat $testsrcinc >> $testsrc
        startsize=`stat -c%s  $testsrc`

        echo  "running for srcsize $(($startsize / 1024 ))kB ...$0 IN $testsrc   OUT $testdone    $methodused"
        $0 IN $testsrc   OUT $testdone    $methodused

        start=$(date +%s)
        echo  "running for srcsize $(($startsize / 1024 ))kB ... $0 IN $testsrc   OUT /dev/null     $methodused"
        $0 IN $testsrc   OUT /dev/null     $methodused    #### remove the time taken by to write the file... only the CPU Times
        now=$(date +%s)


        endsize=`stat -c%s  $testdone`

        ratio_in_10000_pc=$((  $endsize * 100  * 10000 /  $startsize ))
        pcI=$(( $ratio_in_10000_pc   / 10000 ))
        pcD=$(( $ratio_in_10000_pc   % 10000 ))

        timetaken=$((now-start))

        echo "$startsize,$methodused,$pcI.$pcD,$endsize,$timetaken" >>  $rptpath
        sizetouse=$((  $sizetouse +  $sizeincstep ))
    done

    rm -f $testfile
    rm -f $testsrc
    rm -f $testsrcinc
    rm -f $testdone
else
	cd `dirname $0`;
    #GEM_HOME=`ls -1d lib/vendor/bundle/ruby/*`
    RUBYLIB=lib/facter/util/ruby-xz-1.0.0/lib  ${rubycmd}  lib/puppet_x/bigbigfacts/xzpuppetutils.rb  $@
fi;


