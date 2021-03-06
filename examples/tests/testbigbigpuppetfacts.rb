#!/opt/puppetlabs/puppet/bin/ruby -I ../../lib
require 'json'
require 'facter/util/bigbigpuppetfacts'




##### Test Setup
class BBPFTester
  include Facter::Util::Bigbigpuppetfacter
end
bb = BBPFTester.new


# Use case 0 Current
fallback_methods= 'plain'
method2set = 'bz2_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"



# Use case 1
fallback_methods= 'plain'
method2set = 'xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"




# Use case 2
fallback_methods= 'plain'
method2set = 'xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"



# Use case 3
fallback_methods= 'plain'
method2set = 'bz2_base64,xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"



# Use case 4
fallback_methods= 'plain'
method2set = 'gz_base64,bz2_base64,xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"


# Use case 5
fallback_methods= 'gz_base64,bz2_base64,xz_base64,plain'
method2set = 'shits'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback fallback_methods
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"



# Use case 6
bb.use_compressmethod_fallback fallback_methods
methods_to_check="gz_base64,bz2_base64,xz_base64,plain,7z_base74,lzma_base64"
methods_to_check=methods_to_check.split(',')

# methodshashs_to_check=methods_to_check.reduce({}){  | rethash, m|
#   rethash[methods_to_check[0]]=methods_to_check
#   methods_to_check=methods_to_check.rotate
#   rethash
# }
methodshashs_to_check=methods_to_check.reduce({}){  | rethash, m|
  bb.use_compressmethod(m)
  rethash[m]=m==bb.compressmethod_used ? 'Supported' : "Not Supported"
  rethash
}


puts  JSON.pretty_generate(methodshashs_to_check)