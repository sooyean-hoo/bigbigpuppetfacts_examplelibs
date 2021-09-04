#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'base64'
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
end
Facter::Util::Resolution.prepend  Facter::Util::Bigbigpuppetfacts

# module Facter::Util::BigbigpuppetFacter
#     def initialize
#         super
#         @compressmethod     = nil
#     end
#     def use_compressmethod(compressmethod_chosen)
#         @compressmethod = compressmethod_chosen
#     end


#     def value_auto(user_query)
#         value_direct=value(user_query)
#         case value_direct
#         when /^bbpf_xz@'/
#             value_direct=XZ.compress(@code.gsub(/^bbpf_xz@'/,'') )
#         when /^bbpf_xz_base64@/
#             value_direct=XZ.decompress( Base64.decode64(  @code.gsub(/^bbpf_xz_base64@'/,'')  ))
#         else
#             case @compressmethod
#             when 'xz'
#                 value_direct=XZ.compress(@code )
#             when /'xz_base64/
#                 value_direct=XZ.decompress( Base64.decode64(  @code ))
#             end
#         end
#         value_direct
#     end
# end
# Facter.prepend  Facter::Util::BigbigpuppetFacter