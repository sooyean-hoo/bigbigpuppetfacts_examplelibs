# bigbigpuppetfacts


## How to Update the compression/decompression libraries
The followings steps are for Updating the Libraries with new Compressor/Decompressor.
  However, there is a need to update the version of the library. The first 2 steps
    would suffices. There is no need to do any code changes, unless new Gem needs it.

- Edit the Gemfile.mylib

> Add in the gem specification, just like a normal Gemfile. You can get the string
from Gem.org. E.g. for 7z it is "gem 'seven_zip_ruby', '~> 1.2', '>= 1.2.4'"

- Run   rake -f ./Rakefile.local make buildfacterutils    or make buildfacterutils

>
```
Running.....   make buildfacterutils
rm -fr ./lib/vendor
[ -e ./Gemfile.mylib ] && [ -e ./Gemfile ] && cp -f  ./Gemfile  ./Gemfile.makemake15639 && cp -f ./Gemfile.mylib ./Gemfile
/opt/puppetlabs/puppet/bin/bundle install --path ./lib/vendor/bundle ;
[DEPRECATED] The `--path` flag is deprecated because it relies on being remembered across bundler invocations, which bundler will no longer do in future versions. Instead please use `bundle config set --local path './lib/vendor/bundle'`, and stop using this flag
Fetching gem metadata from https://rubygems.org/...
Using bundler 2.2.29
Fetching ruby-xz 1.0.0
Fetching seven_zip_ruby 1.3.0
Fetching rbzip2 0.3.0
Installing ruby-xz 1.0.0
Installing rbzip2 0.3.0
Installing seven_zip_ruby 1.3.0 with native extensions
Bundle complete! 3 Gemfile dependencies, 4 gems now installed.
Bundled gems are installed into `./lib/vendor/bundle`
Post-install message from ruby-xz:
Version 1.0.0 of ruby-xz breaks the API. Read HISTORY.rdoc and adapt your code to the new API.
/opt/puppetlabs/puppet/bin/bundle config set path ' ./lib/vendor/bundle' && /opt/puppetlabs/puppet/bin/bundle install
Your application has set path to "./lib/vendor/bundle". This will override the global value you are currently setting
Using bundler 2.2.29
Using rbzip2 0.3.0
Using ruby-xz 1.0.0
Using seven_zip_ruby 1.3.0
Bundle complete! 3 Gemfile dependencies, 4 gems now installed.
Bundled gems are installed into `./lib/vendor/bundle`
[ -e ./Gemfile.makemake15639 ]  && rm  -f  ./Gemfile  && mv  ./Gemfile.makemake15639  ./Gemfile
echo cleanbundle it.
cleanbundle it.
orgDir=$PWD; \
	find  ./  -iname 'lib' | grep gems | grep vendor | while read lib  ; do  \
		pushd $PWD ;   \
			  lib2move=`echo $lib |   sed -E 's/.+gems\///g'| sed -E 's/lib.+$/lib/g'        ` ;              \
			cd  ./lib/facter/util ; \
		      mkdir -p $lib2move ; \
		      echo "==============================cp -r $orgDir/$lib  $lib2move/../   "; \
			  cp -r $orgDir/$lib  $lib2move/../    ; \
		popd 	;	 \
	done ;
~/Documents/@Work/SCB/codes/bigbigpuppetfacts ~/Documents/@Work/SCB/codes/bigbigpuppetfacts
==============================cp -r /Users/valente/Documents/@Work/SCB/codes/bigbigpuppetfacts/.//lib/vendor/bundle/ruby/2.5.0/gems/seven_zip_ruby-1.3.0/lib  seven_zip_ruby-1.3.0/lib/../
~/Documents/@Work/SCB/codes/bigbigpuppetfacts
~/Documents/@Work/SCB/codes/bigbigpuppetfacts ~/Documents/@Work/SCB/codes/bigbigpuppetfacts
==============================cp -r /Users/valente/Documents/@Work/SCB/codes/bigbigpuppetfacts/.//lib/vendor/bundle/ruby/2.5.0/gems/rbzip2-0.3.0/lib  rbzip2-0.3.0/lib/../
~/Documents/@Work/SCB/codes/bigbigpuppetfacts
~/Documents/@Work/SCB/codes/bigbigpuppetfacts ~/Documents/@Work/SCB/codes/bigbigpuppetfacts
==============================cp -r /Users/valente/Documents/@Work/SCB/codes/bigbigpuppetfacts/.//lib/vendor/bundle/ruby/2.5.0/gems/ruby-xz-1.0.0/lib  ruby-xz-1.0.0/lib/../
~/Documents/@Work/SCB/codes/bigbigpuppetfacts
Cleaning Dependency
Getting the Dependencies, Based on Gemfile
[DEPRECATED] The `--path` flag is deprecated because it relies on being remembered across bundler invocations, which bundler will no longer do in future versions. Instead please use `bundle config set path './lib/vendor/bundle'`, and stop using this flag
Warning: the running version of Bundler (2.1.4) is older than the version that created the lockfile (2.2.29). We suggest you to upgrade to the version that created the lockfile by running `gem install bundler:2.2.29`.
The dependency puppet-module-win-default-r2.6 (~> 1.0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mswin32, x86-mingw32, x64-mingw32. To add those platforms to the bundle, run `bundle lock --add-platform x86-mswin32 x86-mingw32 x64-mingw32`.
The dependency puppet-module-win-dev-r2.6 (~> 1.0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mswin32, x86-mingw32, x64-mingw32. To add those platforms to the bundle, run `bundle lock --add-platform x86-mswin32 x86-mingw32 x64-mingw32`.
The dependency puppet-module-win-system-r2.6 (~> 1.0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mswin32, x86-mingw32, x64-mingw32. To add those platforms to the bundle, run `bundle lock --add-platform x86-mswin32 x86-mingw32 x64-mingw32`.
Unable to use the platform-specific (universal-darwin) version of puppet (7.12.0) because it has different dependencies from the ruby version. To use the platform-specific version of the gem, run `bundle config set specific_platform true` and install again.
Warning: the running version of Bundler (2.1.4) is older than the version that created the lockfile (2.2.29). We suggest you to upgrade to the version that created the lockfile by running `gem install bundler:2.2.29`.
The dependency puppet-module-win-default-r2.6 (~> 1.0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mswin32, x86-mingw32, x64-mingw32. To add those platforms to the bundle, run `bundle lock --add-platform x86-mswin32 x86-mingw32 x64-mingw32`.
The dependency puppet-module-win-dev-r2.6 (~> 1.0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mswin32, x86-mingw32, x64-mingw32. To add those platforms to the bundle, run `bundle lock --add-platform x86-mswin32 x86-mingw32 x64-mingw32`.
The dependency puppet-module-win-system-r2.6 (~> 1.0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mswin32, x86-mingw32, x64-mingw32. To add those platforms to the bundle, run `bundle lock --add-platform x86-mswin32 x86-mingw32 x64-mingw32`.
You can run the utilty using xzpuppetutils.sh now.
```

- Next you need to update the autoload_declare method in the lib/facter/util/bigbigpuppetfacts.rb
with the new library. This is usually based on the main ruby to include. It is base directory which
  house that ruby file. For 7z, it is "./seven_zip_ruby-1.3.0/lib"

- In same function, you would need to do the normal integration of using the autoload
function. You need specify the Constant which is associated with the library, usually
it is the module name or the class name. For 7z. it is the module name, 'SevenZipRuby'.
It is paired with the filename of the main ruby file. This give us the following code.

```
autoload :SevenZipRuby, 'seven_zip_ruby'
```

- The rest are more of how do you want to use the library.
You will be adding procs to the methods which return an hash of procs. You can look
   at the existing elements and do necessary adjustment.

>
1. compressmethods
2. decompressmethods

** There is a few hidden conventions in the naming of the keys to the hash.

>
	- ^ denotes that the compression proc is used from change the data from a certain format, from
	a source which is non-String, while the decompression is vice-versa.
	E.g. ^json
	- :: Sub component of a compressor/decompress. Some compressor and handle multi-formats,
	this is done, so that the user can specify which subcompoents to use. Bzip2 is best
	example for this.




Welcome to your new module. A short overview of the generated parts can be found
in the [PDK documentation][1].

The README template below provides a starting point with details about what
information to include in your README.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with bigbigpuppetfacts](#setup)
    * [What bigbigpuppetfacts affects](#what-bigbigpuppetfacts-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with bigbigpuppetfacts](#beginning-with-bigbigpuppetfacts)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Briefly tell users why they might want to use your module. Explain what your
module does and what kind of problems users can solve with it.

This should be a fairly short description helps the user decide if your module
is what they want.

## Setup

### What bigbigpuppetfacts affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For
example, folks can probably figure out that your mysql_instance module affects
their MySQL instances.

If there's more that they should know about, though, this is the place to
mention:

* Files, packages, services, or operations that the module will alter, impact,
  or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
another module, etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you might want to include an additional "Upgrading" section here.

### Beginning with bigbigpuppetfacts

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most basic
use of the module.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your
users how to use your module to solve problems, and be sure to include code
examples. Include three to five examples of the most important or common tasks a
user can accomplish with your module. Show users how to accomplish more complex
tasks that involve different types, classes, and functions working in tandem.

## Reference

This section is deprecated. Instead, add reference information to your code as
Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your
module. For details on how to add code comments and generate documentation with
Strings, see the [Puppet Strings documentation][2] and [style guide][3].

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the
root of your module directory and list out each of your module's classes,
defined types, facts, functions, Puppet tasks, task plans, and resource types
and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

* The data type, if applicable.
* A description of what the element does.
* Valid values, if the data type doesn't make it obvious.
* Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other
warnings.

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel are
necessary or important to include here. Please use the `##` header.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
