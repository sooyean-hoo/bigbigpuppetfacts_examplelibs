#bbpf Support Matrix
require 'facter'
require 'json'

require 'facter/util/bigbigpuppetfacts'

Facter.add('bbpf_supportmatrix' ) do
  setcode do
	use_compressmethod_fallback 'plain'
	methods_to_check="gz_base64,bz2_base64,xz_base64,plain,Not_Supported,gz,xz,bz2,base64"
	methods_to_check=methods_to_check.split(',')

	methodshashs_to_check=methods_to_check.reduce({}){  | rethash, m|
	  use_compressmethod(m)
	  rethash[m]=m==compressmethod_used ? 'Supported' : "Not Supported"
	  rethash
	}

	methodshashs_to_check
  end
end