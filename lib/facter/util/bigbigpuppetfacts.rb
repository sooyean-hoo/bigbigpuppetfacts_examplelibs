#!/opt/puppetlabs/puppet/bin/ruby

require 'xz'
require 'base64'

module Facter::Util::Bigbigpuppetfacts
    def initialize
        super
        @compressmethod     = nil
    end
    def compress_code
        case @compressmethod
        when 'bbpf_xz'
            @code='bbpf_xz@' + XZ.compress(@code)
        when 'bbpf_xz_base64'
            @code='bbpf_xz_base64@' + XZ.compress(@code)
        when 'xz'
            @code=XZ.compress(@code)
        when 'xz_base64'
            @code=Base64.encode64(XZ.compress(@code))
        end
    end
    def use_compressmethod(compressmethod_chosen)
        @compressmethod = compressmethod_chosen
    end


    def setcode(string = nil, &block)
        super(string, &block)
        compress_code  unless @compressmethod.nil? || @compressmethod.empty?
        self
    end
end
Facter::Util::Resolution.prepend  Facter::Util::Bigbigpuppetfacts

module Facter::Util::BigbigpuppetFacter
    def initialize
        super
        @compressmethod     = nil
    end
    def use_compressmethod(compressmethod_chosen)
        @compressmethod = compressmethod_chosen
    end


    def value_auto(user_query)
        value_direct=value(user_query)
        case value_direct
        when /^bbpf_xz@'/
            value_direct=XZ.compress(@code.gsub(/^bbpf_xz@'/,'') )
        when /^bbpf_xz_base64@/
            value_direct=XZ.decompress( Base64.decode64(  @code.gsub(/^bbpf_xz_base64@'/,'')  ))
        else
            case @compressmethod
            when 'xz'
                value_direct=XZ.compress(@code )
            when /'xz_base64/
                value_direct=XZ.decompress( Base64.decode64(  @code ))
            end
        end
        value_direct
    end
end
Facter.prepend  Facter::Util::BigbigpuppetFacter