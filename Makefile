echo::
	echo Running as Bash CMD FakeMake
	pwd ;
	execution=`egrep  -h -A100 ^$1    $(dirname $0)/./Makefile  |  egrep -v ^$1  | grep -m 1  -h  -B100 : |    sed -E  's/[$][{](.+)[}]/$\1/g' | sed -E 's/[$]{2}/$/g' ` ; \
	echo Command to Execute @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@;  \
	echo "$execution" ; \
	echo Execution @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@;   \
	echo "$execution" >  /tmp/test.sh ;  \
	bash  /tmp/test.sh ;   \
	echo Execution DONE@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@; \
	exit 0;

help::
	@if [ "${t}" = "" ] ; then \
		grep -E "^[a-zA-Z0-9_ ]+[:]+" Makefile   | awk -F":" '{print $$1}' ;  \
			 [[   $$PWD   =~   valentepuppet  ]]  || grep -E "^[a-zA-Z0-9_ ]+[:]+" ~/mym/valentepuppet/Makefile   | awk -F":" '{print $$1}'   ; \
	else \
		grep -E "^[a-zA-Z0-9_ ]+[:]+" Makefile   | grep -i "${t}"  | tr ";:\043" " "  ;   \
			 [[   $$PWD   =~   valentepuppet  ]]  ||   grep -E "^[a-zA-Z0-9_ ]+[:]+" ~/mym/valentepuppet/Makefile   | grep -i "${t}"  | tr ";:\043" " "   ;      \
	fi;
	echo We are at `pwd`


vendordir:=./lib/vendor

clean:
	rm -fr ${vendordir}

all: clean
	bundle install --path ${vendordir}/bundle ;
	bundle config set path ' ${vendordir}/bundle' && bundle install

transferaufvalentepuppet: clean
	rsync -avvpLhrztP *  .*   --exclude 'xzdemorun'  /Users/valente/Documents/@Work/SCB/codes/bigbigpuppetfacts/