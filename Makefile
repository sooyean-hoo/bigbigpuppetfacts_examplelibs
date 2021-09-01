all:
	bundle install --path vendor/bundle ;
	bundle config set path 'vendor/bundle' && bundle install

transferaufvalentepuppet:
	rsync -avvpLhrztP *  .*   --exclude 'xzdemorun'  /Users/valente/Documents/@Work/SCB/codes/bigbigpuppetfacts #&& rm -fr /Users/valente/Documents/@Work/SCB/codes/bigbigpuppetfacts/zxdemorun