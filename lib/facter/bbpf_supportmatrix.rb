# bbpf Support Matrix
require 'facter'
require 'json'

require 'facter/util/bigbigpuppetfacts'

Facter.add('bbpf_supportmatrix') do
  has_weight 10
  confine kernel: ['Linux', 'AIX']
  setcode do
    use_compressmethod_fallback 'plain'
    methods_to_check = 'gz_base64,bz2_base64,xz_base64,plain,Not_Supported'
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

Facter.add('bbpf_supportmatrix') do
  has_weight 10
  confine kernel: ['windows']
  setcode do
    use_compressmethod_fallback 'plain'
    methods_to_check = 'bz2_base64,gz_base64,7z_base64,xz_base64,plain,Not_Supported'
    methods_to_check = methods_to_check.split(',')

    bbpfm = Facter::Util::Bigbigpuppetfacts.compressmethods.keys
    methods_to_check += bbpfm.select { |x| %r{gz::}.match? x } ## Add  All the internal methods...
    methods_to_check += bbpfm.select { |x| %r{bz}.match? x } ## Add  All the internal methods...

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
