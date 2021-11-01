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

all:
	pwd

makeid:=${shell echo "makemake$$$$" }
bundle::
	[ -e ./Gemfile.mylib ] && [ -e ./Gemfile ] && cp -f  ./Gemfile  ./Gemfile.${makeid} && cp -f ./Gemfile.mylib ./Gemfile
	/opt/puppetlabs/puppet/bin/bundle install --path ${vendordir}/bundle ;
	/opt/puppetlabs/puppet/bin/bundle config set path ' ${vendordir}/bundle' && /opt/puppetlabs/puppet/bin/bundle install
	[ -e ./Gemfile.${makeid} ]  && rm  -f  ./Gemfile  && mv  ./Gemfile.${makeid}  ./Gemfile

cleanbundle: clean bundle
	echo cleanbundle it.

buildfacterutils: cleanbundle
	orgDir=$$PWD; \
	find  ./  -iname 'lib' | grep gems | grep vendor | while read lib  ; do  \
		pushd $$PWD ;   \
			  lib2move=`echo $$lib |   sed -E 's/.+gems\///g'| sed -E 's/lib.+$$/lib/g'        ` ;              \
			cd  ./lib/facter/util ; \
		      mkdir -p $$lib2move ; \
		      echo "==============================cp -r $$orgDir/$$lib  $$lib2move/../   "; \
			  cp -r $$orgDir/$$lib  $$lib2move/../    ; \
		popd 	;	 \
	done ;

transferaufvalentepuppet: clean
	rsync -avvpLhrztP *  .*   --exclude 'xzdemorun'  /Users/valente/Documents/@Work/SCB/codes/bigbigpuppetfacts/
	


mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
makefilepath:=${shell ps -af  -p $$$$ | grep Makefile | grep -v grep | grep -v sed |sed -E 's/^.+ ([^ ]+Makefile) .+$$/\1/g' }

transplant_bbpf:
	echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@$$PWD
	srcbase=`dirname ${mkfile_path}` ; \
	rsync -apLhrztP              --exclude=vendor --exclude=.gitignore  $$srcbase/lib $$srcbase/xzpuppetutils.sh               ./ ;

testtransplant_bbpf:
	echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@$$PWD
	srcbase=`dirname ${mkfile_path}` ; \
	rsync -rpLhzP  -c --dry-run   --itemize-changes  --exclude=vendor --exclude=.gitignore  $$srcbase/lib $$srcbase/xzpuppetutils.sh               ./ ;

detransplant_bbpf:
	echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@$$PWD
	srcbase=`dirname ${mkfile_path}` ; \
	rsync -avvpLhrztP  -c --dry-run   --itemize-changes  --exclude=vendor --exclude=.gitignore  $$srcbase/lib $$srcbase/xzpuppetutils.sh  \
		           ./ | egrep  '^[>.]' | cut -d\   -f2 | while read line ; do \
				rsync -pLhzP  -c    ./$$line             /tmp/  ; \
	done ;

testdetransplant_bbpf:
	echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@$$PWD
	srcbase=`dirname ${mkfile_path}` ; \
	rsync -avvpLhrztP  -c --dry-run   --itemize-changes  --exclude=vendor --exclude=.gitignore  $$srcbase/lib $$srcbase/xzpuppetutils.sh  \
		           ./ | egrep  '^[>.]' | cut -d\   -f2 | while read line ; do \
				rsync -pLhzP  -c --dry-run  ./$$line             /tmp/  ; \
	done ;

	
	
