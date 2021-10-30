#!/opt/puppetlabs/puppet/bin/ruby -I ../../lib

require 'facter/util/bigbigpuppetfacts'




##### Test Setup
class BBPFTester
  include Facter::Util::Bigbigpuppetfacter
end
bb = BBPFTester.new





# Use case 1
fallback_methods= 'plain'
method2set = 'xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback 'plain'
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"




# Use case 2
fallback_methods= 'plain'
method2set = 'xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback 'plain'
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"



# Use case 3
fallback_methods= 'plain'
method2set = 'bz2_base64,xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback 'plain'
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"



# Use case 4
fallback_methods= 'plain'
method2set = 'gz_base64,bz2_base64,xz_base64'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback 'plain'
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"



# Use case 5
fallback_methods= 'gz_base64,bz2_base64,xz_base64,plain'
method2set = 'shits'
puts "==fallback_methods=#{fallback_methods}=\n=method2set=#{method2set}="
bb.use_compressmethod_fallback 'plain'
bb.use_compressmethod('^json_' + method2set)
puts "==bb.compressmethod_used=#{bb.compressmethod_used}="
puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
