# Module Bigbigpuppetfacts
require 'json'
require 'base64'
require 'facter'
require 'facter/util/ruby-xz-1.0.0/lib/xz'
require 'facter/util/rbzip2-0.3.0/lib/rbzip2'

## Module for fact compression, compatible with Facter Cache
module Facter::Util::Bigbigpuppetfacts
  #  def use_compressmethod(compressmethod_chosen)
  #    @compressmethod = compressmethod_chosen
  #  end
  #
  #  def setcode(string = nil, &block)
  #    if string.nil?
  #      super(&block)
  #    else
  #      super(string, &block)
  #    end
  #
  #    @code_original = @code
  #    @code = proc do
  #      case @compressmethod
  #      when 'bbpf_xz'
  #        ('bbpf_xz@' + XZ.compress(JSON.generate(@code_original.call))).force_encoding('UTF-8')
  #      when 'bbpf_xz_base64'
  #        ('bbpf_xz_base64@' + Base64.encode64(XZ.compress(JSON.generate(@code_original.call))))
  #      when 'xz'
  #        (XZ.compress(JSON.generate(@code_original.call))).force_encoding('UTF-8')
  #      when 'xz_base64'
  #        Base64.encode64(XZ.compress(JSON.generate(@code_original.call)))
  #      else
  #        @code_original.call
  #      end
  #    end
  #    self
  #  end
  class << self
    def use_compressmethod(compressmethod_chosen)
      @compressmethod = compressmethod_chosen
    end

    def value(user_query, compressmethod_to_use = 'auto')
      value_direct = Facter.value(user_query)

      compressmethod_to_use = @compressmethod if compressmethod_to_use == 'auto'

      if %r{-dump.}.match?(user_query)
        clear_value_direct = value_direct
        value_direct = user_query.gsub(%r{.}, '_') ### System will use the key to know the compression
      end

      case value_direct
      when %r{^bbpf_xz@}
        value_direct = XZ.compress(value_direct.gsub(%r{^bbpf_xz@}, ''))
      when %r{^bbpf_xz_base64@}
        value_direct = XZ.decompress(Base64.decode64(value_direct.gsub(%r{^bbpf_xz_base64@}, '')))
        value_direct = JSON.parse(value_direct)
      when %r{xz_base64}
        value_direct = clear_value_direct
        value_direct = XZ.decompress(Base64.decode64(value_direct))
        value_direct = JSON.parse(value_direct)
      else
        case compressmethod_to_use
        when 'xz'
          value_direct = XZ.compress(value_direct)
        when 'xz_base64'
          value_direct = XZ.decompress(Base64.decode64(value_direct))
          value_direct = JSON.parse(value_direct)
        else
          value_direct
        end
      end
      value_direct
    end

    def compressmethods
      {
        'bbpf_xz' => proc { |data| 'bbpf_xz@' + XZ.compress(data) },
       'bbpf_xz_base64' => proc { |data| 'bbpf_xz_base64@' + Base64.encode64(XZ.compress(data)) },

       'xz' => proc { |data| XZ.compress(data) },
       'xz_base64' => proc { |data| Base64.encode64(XZ.compress(data)) },

       'bz' => proc { |data|
         bz2 = RBzip2.default_adapter::Compressor.new(StringIO.new(data)) # wrap the file into the compressor
         bz2.write data # write the raw data to the compressor
         bz2.close
         data
       },

        'base64' => proc { |data| Base64.encode64(data) },
        '^json' => proc { |data|
                     begin
                       JSON.generate(data)
                     rescue
                       data
                     end
                   },
        '^yaml' => proc { |data|
                     begin
                       YAML.dump(data)
                     rescue
                       data
                     end
                   },

        'plain' => proc { |data| data }
      }
    end

    def decompressmethods
      {
        'bbpf_xz' => proc { |data| XZ.decompress(data.gsub(%r{^bbpf_xz@}, '')) },
       'bbpf_xz_base64' => proc { |data| XZ.decompress(Base64.decode64(data.gsub(%r{^bbpf_xz_base64@}, ''))) },

       'xz' => proc { |data| XZ.decompress(data) },
       'xz_base64' => proc { |data| XZ.decompress(Base64.decode64(data)) },

       'bz' => proc { |data|
         bz2  = RBzip2.default_adapter::Decompressor.new(StringIO.new(data)) # wrap the file into the decompressor
         data = bz2.read
         bz2.close
         data
       },

       'base64' => proc { |data| Base64.decode64(data) },
       '^json' => proc { |data|
                    begin
                      JSON.parse(data)
                    rescue
                      data
                    end
                  },
       '^yaml' => proc { |data|
                    begin
                      YAML.safe_load(data)
                    rescue
                      data
                    end
                  },

        'plain' => proc { |data| data }
      }
    end

    def decompress(data, method)
      methodprocs = method.split('_').map { |m| decompressmethods[m] }
      pipeprocess(data, methodprocs)
    end

    def compress(data, method)
      methodprocs = method.split('_').reverse.map { |m| compressmethods[m] }
      pipeprocess(data, methodprocs)
    end

    def pipeprocess(data, processpipe)
      processpipe.reduce(data) do |data__, p|
        p.call(data__)
      end
    end

    def testdata
      "SOOYEANISTESTINGCOMPRESSFACTWITH THIS STRING=+_` <[{ 'aaaa':'a0/s'}]>|!/?@@@@\#\$#%$@^%$#^%^$&^&%*&*(&^(&^)*&^)*&`\"\\"
    end

    def checkmethod(method, fallback_method = 'plain')
      testdata
      begin
        testdataend = decompress(compress(testdata, method), method)
        method = fallback_method unless testdata == testdataend
      rescue
        method = fallback_method
      end
      method
    end

    def compressed_factname_info(factname, _compressmethod)
      factname_info = "#{factname}-info"
      factname_info
    end

    def compressed_factname_dump(factname, compressmethod)
      factname_data = "#{factname}-dump.#{compressmethod.tr('_', '.')}"
      factname_data
    end

    def compressed_factnames(factname, compressmethod)
      [ compressed_factname_info(factname, compressmethod), compressed_factname_dump(factname, compressmethod) ]
    end

    def summarise(srcdata, summariseoptions, summarisedversion = {})
      if summariseoptions.is_a? Hash
        summariseoptions.each do |k0, v0|
          if  (k0.is_a? String) && (k0 =~ %r{^/.+/$}) ## If  a regex, expand into all matches
            p = k0.gsub(%r{^[\./]}, '').gsub(%r{[/]$}, '')
            pattern2use = Regexp.new(p)
            keys_matches = srcdata.select { |k1, _v1| (pattern2use.match k1) || pattern2use.match(k1.to_s) }.keys
            # summarisedversion.merge!(hh)
            summariseoptions_inuse = {}
            keys_matches.each { |k_match| summariseoptions_inuse[k_match] = v0 }
          else ## If not a regex, there will only 1 match
            summariseoptions_inuse = { k0 => v0 }
          end
          summariseoptions_inuse.each do |k, v|
            if v == '*' && !srcdata[k].nil?
              summarisedversion[k] = srcdata[k]
            elsif v.is_a?(Hash) && !srcdata[k].nil?
              summarisedversion[k] = {}
              summarise(srcdata[k], v, summarisedversion[k])
            elsif v.is_a?(Array) && !srcdata[k].nil?
              summarisedversion[k] = []
              summarise(srcdata[k], v, summarisedversion[k])
            elsif srcdata.key?(k) && !srcdata[k].nil?
              summarisedversion[k] = srcdata[k]
            elsif srcdata.key?(k.to_sym) && !srcdata[k.to_sym].nil?
              summarisedversion[k] = srcdata[k.to_sym]
            end
          end
        end
      elsif summariseoptions.is_a? Array
        summarisedversion = [] unless summarisedversion.is_a? Array
        srcdata.each do |x|
          new_e = summarise(x, summariseoptions[0])
          summarisedversion.push(new_e)
        end
      end
      summarisedversion
    end
  end
end

# Module to Help in Resolution when using Bigbigpuppetfacter for setting Compression Method.
module Facter::Util::Bigbigpuppetfacter
  def use_compressmethod(compressmethod_chosen)
    return if @compressmethod == compressmethod_chosen
    compressmethod_chosen = Facter::Util::Bigbigpuppetfacts.checkmethod(compressmethod_chosen)
    @compressmethod = compressmethod_chosen
  end

  def use_compressmethod_fallback(compressmethod_chosen)
    @compressmethod_fallback = compressmethod_chosen
  end

  def compress(value, method = 'plain')
    @compressmethod_fallback = 'plain' if @compressmethod_fallback.nil?
    if !value.is_a?(String) && !%r{^[\^]}.match?(method)
      method = '^json_' + method
    end
    Facter::Util::Bigbigpuppetfacts.compress(value, method)
    #      [
    #        Facter::Util::Bigbigpuppetfacts.compressmethods[method],
    #        Facter::Util::Bigbigpuppetfacts.compressmethods[ @compressmethod_fallback ],
    #      ].compact[0].call(
    #        JSON.generate(value),
    #      )
  end

  def decompress(_compressed_value, method = 'plain')
    @compressmethod_fallback = 'plain' if @compressmethod_fallback.nil?
    Facter::Util::Bigbigpuppetfacts.decompress(value, method)
    #      [
    #        Facter::Util::Bigbigpuppetfacts.decompressmethods[method],
    #        Facter::Util::Bigbigpuppetfacts.decompressmethods[ @compressmethod_fallback ],
    #      ].compact[0].call(
    #        JSON.generate(value),
    #      )
  end
end
Facter::Util::Resolution.include Facter::Util::Bigbigpuppetfacter

# Facter::Util::Resolution.prepend Facter::Util::Bigbigpuppetfacts
# module Facter::Util::Bigbigpuppetfacter
#  class << self
#    def use_compressmethod(compressmethod_chosen)
#      @compressmethod = compressmethod_chosen
#    end
#
#    def value(user_query)
#      value_direct = super(user_query)
#      case value_direct
#      when %r{^bbpf_xz@}
#        value_direct = XZ.compress(value_direct.gsub(%r{^bbpf_xz@}, ''))
#      when %r{^bbpf_xz_base64@}
#        value_direct = XZ.decompress(Base64.decode64(value_direct.gsub(%r{^bbpf_xz_base64@}, '')))
#        value_direct = JSON.parse(value_direct)
#      else
#        case @compressmethod
#        when 'xz'
#          value_direct = XZ.compress(value_direct)
#        when 'xz_base64'
#          value_direct = XZ.decompress(Base64.decode64(value_direct))
#          value_direct = JSON.parse(value_direct)
#        else
#          value_direct
#        end
#      end
#      value_direct
#    end
#  end
# end
# Facter.prepend Facter::Util::Bigbigpuppetfacter
# module Facter
#  class << self
#    def use_compressmethod(compressmethod_chosen)
#      Facter::Util::Bigbigpuppetfacts.use_compressmethod(compressmethod_chosen)
#    end
#
#    def value_a(user_query)
#      Facter::Util::Bigbigpuppetfacts.value(user_query)
#    end
#  end
# end
