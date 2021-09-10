#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'base64'
require 'facter'
require_relative '../../facter/util/ruby-xz-1.0.0/lib/xz'

module Facter::Util::Bigbigpuppetfacts
    def use_compressmethod(compressmethod_chosen)
        @compressmethod = compressmethod_chosen
    end
    def setcode(string = nil, &block)
        
        if string.nil? 
            super(&block)
        else
            super(string, &block)
        end

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

            if user_query =~ /-dump./
                clear_value_direct = value_direct
                value_direct = user_query.gsub(/./,'_')    ### System will use the key to know the compression
            end

            case value_direct
            when /^bbpf_xz@/
                value_direct=XZ.compress(value_direct.gsub(/^bbpf_xz@/,'') )
            when /^bbpf_xz_base64@/
                value_direct=XZ.decompress( Base64.decode64(  value_direct.gsub(/^bbpf_xz_base64@/,'')  ))
                value_direct=JSON.parse(value_direct)
            when /xz_base64/
                value_direct = clear_value_direct
                value_direct=XZ.decompress( Base64.decode64(  value_direct ))
                value_direct=JSON.parse(value_direct)
            else
                case @compressmethod
                when 'xz'
                    value_direct=XZ.compress(value_direct )
                when 'xz_base64'
                    value_direct=XZ.decompress( Base64.decode64(  value_direct))
                    value_direct=JSON.parse(value_direct)
                else
                    value_direct
                end
            end
            value_direct
        end

       def compressmethods
            {
             'bbpf_xz' => Proc.new { | data |  'bbpf_xz@' + XZ.compress( data )   } ,
             'bbpf_xz_base64' => Proc.new { | data | 'bbpf_xz_base64@' +  Base64.encode64(XZ.compress(data ) )  } ,

             'xz' => Proc.new { | data |   XZ.compress( data )   } ,
             'xz_base64' => Proc.new { | data |  Base64.encode64(XZ.compress(data ) )  }

            }
        end
        def decompressmethods
            {
             'bbpf_xz' => Proc.new { | data |  'bbpf_xz@' + XZ.decompress( data.gsub(/^bbpf_xz@/,'') )   } ,
             'bbpf_xz_base64' => Proc.new { | data | 'bbpf_xz_base64@' +  XZ.decompress(Base64.decode64(data.gsub(/^bbpf_xz_base64@/,'') ) )  } ,

             'xz' => Proc.new { | data |   XZ.compress( data )   } ,
             'xz_base64' => Proc.new { | data |  Base64.encode64(XZ.compress(data ) )  }

            }
        end

    end
end
Facter::Util::Resolution.prepend  Facter::Util::Bigbigpuppetfacts
# module Facter::Util::Bigbigpuppetfacter
#     class << self
#         def use_compressmethod(compressmethod_chosen)
#             @compressmethod = compressmethod_chosen
#         end
#         def value(user_query)
#             value_direct=super(user_query)
#             case value_direct
#             when /^bbpf_xz@/
#                 value_direct=XZ.compress(value_direct.gsub(/^bbpf_xz@/,'') )
#             when /^bbpf_xz_base64@/
#                 value_direct=XZ.decompress( Base64.decode64(  value_direct.gsub(/^bbpf_xz_base64@/,'')  ))
#                 value_direct=JSON.parse(value_direct)
#             else
#                 case @compressmethod
#                 when 'xz'
#                     value_direct=XZ.compress(value_direct )
#                 when 'xz_base64'
#                     value_direct=XZ.decompress( Base64.decode64(  value_direct))
#                     value_direct=JSON.parse(value_direct)
#                 else
#                     value_direct
#                 end
#             end
#             value_direct
#         end
#     end
# end
# Facter.prepend Facter::Util::Bigbigpuppetfacter
module Facter
    class << self
        def use_compressmethod(compressmethod_chosen)
            Facter::Util::Bigbigpuppetfacts.use_compressmethod(compressmethod_chosen)
        end
        def value_a(user_query)
            Facter::Util::Bigbigpuppetfacts.value(user_query)
        end
    end
end
