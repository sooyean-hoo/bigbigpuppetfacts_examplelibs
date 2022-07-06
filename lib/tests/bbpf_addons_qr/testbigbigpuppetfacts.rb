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

    bbpf_drivers([ File.join(File.dirname(__FILE__), '../../../lib/puppet_x/bigbigfacts/drivers/*.rb') ])

    methods_to_check = [ 'qr', 'barcode' ]

    methods_to_check = methods_to_check.select { |x| x.split('_').all? { |x_part| Facter::Util::Bigbigpuppetfacts.compressmethods.key?(x_part) } }
    methods_to_check << 'Not_Supported'

    # methodshashs_to_check =
    methods_to_check.uniq.each_with_object({}) do |m, rethash|
      hash_key = m.match?(%r{^[\^]}) ? "plain_#{m.gsub(%r{^[\^]}, '')}" : m

      begin
        use_compressmethod(m)
        rethash[hash_key] = m == compressmethod_used ? 'Supported' : 'Not Supported'
      rescue LoadError
        rethash[hash_key] = 'Not Supported - Fatal Crash'
      end
    end
  end

  def bbpf_supportmatrix_factertest
    use_compressmethod_fallback 'plain'
    methods_to_check = 'gz_base64,bz2_base64,xz_base64,plain,7z_base74,lzma_base64'
    methods_to_check = methods_to_check.split(',')

    # Add in all methods solo...
    bbpfm = Facter::Util::Bigbigpuppetfacts.compressmethods.keys
    methods_to_check += bbpfm - ['^nil::'] ## Remove  ^nil
    methods_to_check = methods_to_check.reject { |x| %r{^::}.match? x } ## Remove  All the internal methods...
    methods_to_check = methods_to_check.reject { |x| %r{::shellout}.match? x } ## Remove  All the shellout methods...
    methods_to_check = methods_to_check.reject { |x| %r{simulate}.match? x } ## Remove  All the simulate methods...
    methods_to_check = methods_to_check.reject { |x| %r{bbpf}.match? x } ## Remove  All the bbpf methods...
    methods_to_check = methods_to_check.reject { |x| %r{dataurl}.match? x } ## Remove  All the bbpf methods...
    methods_to_check = methods_to_check.reject { |x| %r{bash}.match? x } ## Remove  All the bash methods...
    # methods_to_check +=   bbpfm.select { |x| %r{::shellout}.match?(x) && %r{7z::}.match?(x) } ## Add All the 7z shellout...

    # methods_to_check = methods_to_check.map{ |y|   y.match?(/^[\^]/) ? "plain_#{y.gsub(/^[\^]/,'') }" : y }
    methods_to_check = methods_to_check.select { |x| x.split('_').all? { |x_part| Facter::Util::Bigbigpuppetfacts.compressmethods.key?(x_part) } }
    methods_to_check << 'Not_Supported'

    methodshashs_to_check = methods_to_check.uniq.each_with_object({}) do |m, rethash|
      hash_key = m.match?(%r{^[\^]}) ? "plain_#{m.gsub(%r{^[\^]}, '')}" : m

      begin
        use_compressmethod(m)
        rethash[hash_key] = m == compressmethod_used ? 'Supported' : 'Not Supported'
      rescue LoadError
        rethash[hash_key] = 'Not Supported - Fatal Crash'
      end
    end

    methodshashs_to_check
  end
end
bb = BBPFTester.new

result = bb.bbpf_supportmatrixtest
puts JSON.pretty_generate(result)
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 0 Current
fallback_methods = 'plain'
method2set = 'qr'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
#bb.use_compressmethod('^json_' + method2set)
bb.use_compressmethod( method2set)
puts bb.compress('http://www.yahoo.com')
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 1
fallback_methods = 'plain'
method2set = 'barcode'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
#bb.use_compressmethod('^json_' + method2set)
bb.use_compressmethod( method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

# Use case 2
methodshashs_to_check = bb.bbpf_supportmatrix_factertest

puts JSON.pretty_generate(methodshashs_to_check)
