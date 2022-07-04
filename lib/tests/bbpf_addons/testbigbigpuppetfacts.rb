#!/opt/puppetlabs/puppet/bin/ruby -I ../../lib

## Before running this test...
## Run the following preparation code first at the module root folder
## OLD bbpfcodedir=$PWD/../`basename $PWD ` ; mkdir -p /tmp/media ;  cd  /tmp/media ; rsync -avvphrz $bbpfcodedir ./ ; cd `basename $bbpfcodedir ` ; git reset --hard ; git checkout 4publicversion ;
# bbpfcodedir=$PWD/../`basename $PWD ` ; mkdir -p /tmp/media ;  cd  /tmp/media ; git clone $bbpfcodedir    ; cd `basename $bbpfcodedir ` ; git reset --hard ; git checkout 4publicversion ;

lib_path = File.join(File.dirname(__FILE__), '../../../lib/')
$LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

lib_path = '/tmp/media/bigbigpuppetfacts/lib/'
$LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

require 'json'
require 'facter/util/bigbigpuppetfacts'

##### Test Setup
class BBPFTester
  include Facter::Util::Bigbigpuppetfacter

  def bbpf_supportmatrixtest
    methods_to_check = [ 'xz', 'xz_base64' ]

    # methodshashs_to_check =
    methods_to_check.uniq.each_with_object({}) do |m, rethash|
      hash_key = m.match?(%r{^[\^]}) ? "plain_#{m.gsub(%r{^[\^]}, '')}" : m

      bbpf_drivers( [ File.join(File.dirname(__FILE__), '../../../lib/puppet_x/bigbigfacts/drivers/*.rb')  ])

      begin
        use_compressmethod(m)
        rethash[hash_key] = m == compressmethod_used ? 'Supported' : 'Not Supported'
      rescue LoadError
        rethash[hash_key] = 'Not Supported - Fatal Crash'
      end
    end
  end
end
bb = BBPFTester.new

result = bb.bbpf_supportmatrixtest
puts JSON.pretty_generate(result)
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 0 Current
fallback_methods = 'plain'
method2set = 'bz2_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 1
fallback_methods = 'plain'
method2set = 'xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 2
fallback_methods = 'plain'
method2set = 'xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 3
fallback_methods = 'plain'
method2set = 'bz2_base64,xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 4
fallback_methods = 'plain'
method2set = 'gz_base64,bz2_base64,xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 5
fallback_methods = 'gz_base64,bz2_base64,xz_base64,plain'
method2set = 'shits'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 6
bb.use_compressmethod_fallback fallback_methods
methods_to_check = 'gz_base64,bz2_base64,xz_base64,plain,7z_base74,lzma_base64'
methods_to_check = methods_to_check.split(',')

# methodshashs_to_check=methods_to_check.reduce({}){  | rethash, m|
#   rethash[methods_to_check[0]]=methods_to_check
#   methods_to_check=methods_to_check.rotate
#   rethash
# }
methodshashs_to_check = methods_to_check.each_with_object({}) do |m, rethash|
  bb.use_compressmethod(m)
  rethash[m] = m == bb.compressmethod_used ? 'Supported' : 'Not Supported'
end

puts JSON.pretty_generate(methodshashs_to_check)
