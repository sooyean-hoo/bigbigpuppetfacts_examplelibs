# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include bigbigpuppetfacts::profile::compressfactsgems
class bigbigpuppetfacts::profile::compressfactsgems {
  package { ['ruby-xz','rbzip2']:
    ensure   => present,
    provider => puppet_gem,
    # If a custom RubyGem repository needs to be used (such as an internal
    # mirror, or corporate Artifactory repo), pass it with `source`.
    # https://puppet.com/docs/puppet/7/types/package.html#package-provider-gem
    source   => 'https://rubygems.org',
  }
}
