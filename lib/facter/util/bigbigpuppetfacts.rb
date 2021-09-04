#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'base64'
require 'facter'
require 'facter/util/ruby-xz-1.0.0/lib/xz'

module Facter::Util::Bigbigpuppetfacts
    def use_compressmethod(compressmethod_chosen)
        @compressmethod = compressmethod_chosen
    end

    def setcode(string = nil, &block)
        super(string, &block)
        @code_original = @code
        @code = proc do
            case @compressmethod
            when 'bbpf_xz'
                ('bbpf_xz@' + XZ.compress(   JSON.generate(@code_original.call)       )).force_encoding('UTF-8')
            when 'bbpf_xz_base64'
                ('bbpf_xz_base64@' + Base64.encode64(XZ.compress(   JSON.generate(@code_original.call)       )))
            when 'xz'
                (XZ.compress(   JSON.generate(@code_original.call)       )).force_encoding('UTF-8')
            when 'xz_base64'
                (Base64.encode64(XZ.compress(   JSON.generate(@code_original.call)       )))
            else
                @code_original.call
            end
          end
        self
    end
    class << self
        def use_compressmethod(compressmethod_chosen)
            @compressmethod = compressmethod_chosen
        end
        def value(user_query)
            value_direct=Facter.value(user_query)
            case value_direct
            when /^bbpf_xz@'/
                value_direct=XZ.compress(value_direct.gsub(/^bbpf_xz@/,'') )
            when /^bbpf_xz_base64@/
                value_direct=XZ.decompress( Base64.decode64(  value_direct.gsub(/^bbpf_xz_base64@/,'')  ))
                value_direct=JSON.parse(value_direct)
            else
                case @compressmethod
                when 'xz'
                    value_direct=XZ.compress(value_direct )
                when /'xz_base64/
                    value_direct=XZ.decompress( Base64.decode64(  value_direct))
                    value_direct=JSON.parse(value_direct)
                else
                    value_direct
                end
            end
            value_direct
        end
    end
end
Facter::Util::Resolution.prepend  Facter::Util::Bigbigpuppetfacts
module Facter::Util::Bigbigpuppetfacter
    class << self
        def use_compressmethod(compressmethod_chosen)
            @compressmethod = compressmethod_chosen
        end
        def value(user_query)
            value_direct=super(user_query)
            case value_direct
            when /^bbpf_xz@'/
                value_direct=XZ.compress(value_direct.gsub(/^bbpf_xz@/,'') )
            when /^bbpf_xz_base64@/
                value_direct=XZ.decompress( Base64.decode64(  value_direct.gsub(/^bbpf_xz_base64@/,'')  ))
                value_direct=JSON.parse(value_direct)
            else
                case @compressmethod
                when 'xz'
                    value_direct=XZ.compress(value_direct )
                when /'xz_base64/
                    value_direct=XZ.decompress( Base64.decode64(  value_direct))
                    value_direct=JSON.parse(value_direct)
                else
                    value_direct
                end
            end
            value_direct
        end
    end
end
Facter.prepend Facter::Util::Bigbigpuppetfacter
Facter::Util::Resolution.prepend  Facter::Util::Bigbigpuppetfacts
module Facter
    class << self
        def use_compressmethod(compressmethod_chosen)
            Facter::Util::Bigbigpuppetfacts.use_compressmethod(compressmethod_chosen)
        end
        def value_auto(user_query)
            Facter::Util::Bigbigpuppetfacts.value(user_query)
        end
    end
end
