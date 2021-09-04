# Rakefile
task default: [:clean, :build]

task :clean do
    puts "Cleaning Dependency"
    `rm -fr ./vendor`
end

task :build do
    puts "Getting the Dependencies, Based on Gemfile"
    `bundle install --path vendor/bundle`
	`bundle config set path 'vendor/bundle' && bundle install`
    puts 'You can run the utilty using xzpuppetutils.sh now.'
end

task :transferaufvalentepuppet do
    puts "Getting the Files Read to go to GitHub"
    `rsync -avvpLhrztP *  .*   --exclude 'xzdemorun'  /Users/valente/Documents/@Work/SCB/codes/bigbigpuppetfacts #&& rm -fr /Users/valente/Documents/@Work/SCB/codes/bigbigpuppetfacts/zxdemorun`
    puts 'Getting files to the Deploy Directory For Github Checkins.'
end

task buildfacterutils: [:clean, :build] do
	command=<<-'cmd'
orgDir=$PWD; \
	find  ./  -iname 'lib' | grep gems | grep vendor | while read lib  ; do  \
		pushd $PWD ;   \
			  lib2move=`echo $lib |   sed -E 's/.+gems\///g'| sed -E 's/lib.+$/lib/g'        ` ;              \
			cd  ./lib/facter/util ; \
		      mkdir -p $lib2move ; \
			  cp -r $orgDir/$lib  $lib2move/../    ; \
		popd 	;	 \
	done ;
	cmd
	%x[ #{command} ]
end