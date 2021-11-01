# Module Bigbigpuppetfacts
require 'json'
require 'base64'
require 'facter'

# require 'facter/util/ruby-xz-1.0.0/lib/xz'
# require 'facter/util/rbzip2'

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
    attr_writer :namedelim

    def namedelim
      @namedelim = '_' if @namedelim.nil? # Used to be .
      @namedelim
    end

    def set_namedelim_=(delim)
      @namedelim_ = delim
    end

    def namedelim_
      @namedelim_ = '_' if @namedelim_.nil?
      @namedelim_
    end

    def use_compressmethod(compressmethod_chosen)
      @compressmethod = compressmethod_chosen
    end

    #    def value(user_query, compressmethod_to_use = 'auto')
    #      value_direct = Facter.value(user_query)
    #
    #      compressmethod_to_use = @compressmethod if compressmethod_to_use == 'auto'
    #
    #      if %r{-dump.}.match?(user_query)
    #        clear_value_direct = value_direct
    #        value_direct = user_query.gsub(%r{.}, '_') ### System will use the key to know the compression
    #      end
    #
    #      case value_direct
    #      when %r{^bbpf_xz@}
    #        value_direct = XZ.compress(value_direct.gsub(%r{^bbpf_xz@}, ''))
    #      when %r{^bbpf_xz_base64@}
    #        value_direct = XZ.decompress(Base64.decode64(value_direct.gsub(%r{^bbpf_xz_base64@}, '')))
    #        value_direct = JSON.parse(value_direct)
    #      when %r{xz_base64}
    #        value_direct = clear_value_direct
    #        value_direct = XZ.decompress(Base64.decode64(value_direct))
    #        value_direct = JSON.parse(value_direct)
    #      else
    #        case compressmethod_to_use
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

    def autoload_declare
      lib_path = File.join(File.dirname(__FILE__), './bzip2-ffi-1.1.0/lib/')
      $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

      lib_path = File.join(File.dirname(__FILE__), './rbzip2-0.3.0/lib/')
      $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

      lib_path = File.join(File.dirname(__FILE__), './ruby-xz-1.0.0/lib/')
      $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

      lib_path = File.join(File.dirname(__FILE__), './seven_zip_ruby-1.3.0/lib/')
      $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

      lib_path = File.join(File.dirname(__FILE__), './simple_compress-0.0.1/lib/')
      $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

      lib_path = File.dirname(__FILE__)
      $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

      lib_path = File.join(File.dirname(__FILE__), '../../')
      $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

      autoload :XZ, 'xz'
      autoload :RBzip2, 'rbzip2'
      autoload :SevenZipRuby, 'seven_zip_ruby'
      autoload :SimpleCompress, 'simple_compress'
      autoload :Zlib, 'zlib'
      autoload :Bzip2, 'bzip2/ffi'

      autoload :Open3, 'open3'
    end

    DEFAULT_ERROR_MSG = 'FATAL ERROR During Processing: Please use another processing method.'.freeze
    # :: denote sub compression methods
    def compressmethods
      autoload_declare
      {
        #        'bbpf_xz' => proc { |data| 'bbpf_xz@' + XZ.compress(data) },
        #       'bbpf_xz_base64' => proc { |data| 'bbpf_xz_base64@' + Base64.encode64(XZ.compress(data)) },

        # inbuild method is now prefix with ::
        '::shellout' => proc { |data, cmd1 = 'tee', cmd2 = 'tee', cmd3 = 'tee', _info: {}|
          Open3.pipeline_rw(cmd1, cmd2, cmd3) do |i, o, _ts|
            i.puts data
            i.close
            o.read
          end
        },
        '::error' => proc { |_data, error_msg = '', error_msg_prefix = '', error_msg_postfix = '', _info: {}|
                       error_msg = checkmethod_geterrormsg if error_msg.empty?
                       error_msg = DEFAULT_ERROR_MSG if error_msg.nil? || error_msg.empty?
                       error_msg_prefix + error_msg + error_msg_postfix
                     },
        '::simulateruntimeerror' => proc { |data, _info: {}|
                                      unless ENV['simulateruntimeerror'].nil? || ENV['simulateruntimeerror'].empty?
                                        raise NameError, ENV['simulateruntimeerror'] if ENV['simulateruntimeerror'].include? 'NameError'
                                        ::FFI::Library.ffi_lib ['/lib/NOSUCHTHING'] if ENV['simulateruntimeerror'].include? 'LoadError'
                                        raise StandardError, ENV['simulateruntimeerror'] if ENV['simulateruntimeerror'].include? 'ERROR'
                                        raise ENV['simulateruntimeerror']
                                      end
                                      data
                                    },
        'simulateruntimeerror' => proc { |data, _info: {}|
                                    compressmethods['::simulateruntimeerror'].call(data)
                                  },

        # 7z, zip, gzip, bzip2 or tar. 7z xz
        '7z::xz::shellout' => proc { |data, _info: {}|
                                compressmethods['::shellout'].call(data, '7za -txz -an -si -so     a', 'tee')
                              },
        '7z::gzip::shellout' => proc { |data, _info: {}|
                                  compressmethods['::shellout'].call(data, '7za -tgzip -an -si -so     a', 'tee')
                                },
        '7z::bzip2::shellout' => proc { |data, _info: {}|
                                   compressmethods['::shellout'].call(data, '7za -tbzip2 -an -si -so     a', 'tee')
                                 },
        '7z::zip::shellout' => proc { |data, _info: {}|
                                 compressmethods['::shellout'].call(data, '7za -tzip -an -si -so     a', 'tee')
                               },
        '7z::shellout' => proc { |data, _info: {}|
                            compressmethods['::shellout'].call(data, '7za -txz -an -si -so     a', 'tee')
                          },
        '7z::' => proc { |data, _info: {}|
                    dfile = StringIO.new('')
                    SevenZipRuby::Writer.open(dfile) do |szr|
                      szr.add_data data, 'file.bin'
                    end
                    data = dfile.string
                    data
                  },

        'gz::simplecompress' => proc { |data, _info: {}| SimpleCompress.compress(data) },
        'gz::zlibgzip' => proc { |data, _info: {}|
          buf = StringIO.new
          gz = Zlib::GzipWriter.new(buf)
          gz.write(data)
          gz.close
          buf.string.force_encoding(Encoding::BINARY)
        },
        'gz::zlib' => proc { |data, _info: {}| Zlib::Deflate.deflate(data, Zlib::BEST_COMPRESSION) },
        'gz' => proc { |data, _info: {}| compressmethods['gz::zlibgzip'].call(data) },

       'xz' => proc { |data, _info: {}| XZ.compress(data) },

       'bz2::ffi' => proc { |data, _info: {}|
                       dfile = StringIO.new('')
                       bz2 = RBzip2::FFI::Compressor.new(dfile) # wrap the file into the compressor
                       bz2.write data # write the raw data to the compressor
                       bz2.close
                       data = dfile.string
                       data
                     },
        'bz2::java' => proc { |data, _info: {}|
                         dfile = StringIO.new('')
                         bz2 = RBzip2::Java::Compressor.new(dfile) # wrap the file into the compressor
                         bz2.write data # write the raw data to the compressor
                         bz2.close
                         data = dfile.string
                         data
                       },
        'bz2::ruby' => proc { |data, _info: {}|
                         dfile = StringIO.new('')
                         bz2 = RBzip2::Ruby::Compressor.new(dfile) # wrap the file into the compressor
                         bz2.write data # write the raw data to the compressor
                         bz2.close
                         data = dfile.string
                         data
                       },

        'bz2::cmd' => proc { |data, _info: {}|
                        compressmethods['::shellout'].call(data, 'bzip2 -z --best -s -qc ', 'tee')
                      },

        'bz2::auto' => proc { |data, _info: {}|
          dfile = StringIO.new('')
          bz2 = RBzip2.default_adapter::Compressor.new(dfile) # wrap the file into the compressor
          bz2.write data # write the raw data to the compressor
          bz2.close
          data = dfile.string
          data
        },

        'bzip2' => proc { |data, _info: {}|
          dfile = StringIO.new('')
          Bzip2::FFI::Writer.write(dfile, data)
          data = dfile.string
          data
        },

       'bz2' => proc { |data, _info: {}|
                  begin
                    compressmethods['bzip2'].call(data)
                  rescue NameError, LoadError, Bzip2::FFI::Error::MagicDataError
                    begin
                      compressmethods['bz2::auto'].call(data)
                    rescue NameError, LoadError
                      compressmethods['bz2::ruby'].call(data)
                    end
                  end
                },

        'base64' => proc { |data, _info: {}| Base64.encode64(data) },

        '^json' => proc { |data, _info: {}|
                     begin
                       JSON.generate(data)
                     rescue
                       data
                     end
                   },
        '^yaml' => proc { |data, _info: {}|
                     begin
                       YAML.dump(data)
                     rescue
                       data
                     end
                   },

        'bbpf'  => proc { |data, _info: {}| # rubocop:disable Lint/UnderscorePrefixedVariableName
          _info['m'] = _info['m'].gsub(%r{bbpf_}, '')
          m = 'bbpf::start' + namedelim_ + (_info['m']).to_s + namedelim_ + 'bbpf::end'
          data = compress(data, m)
          _info['continue'] = false
          data
        }, # Special Method which prefix the final Data with the compression methods/process e.g. "bbpf_XX_YY"
        'bbpf::start' => proc { |data, _info: {}| data }, # Special Method which prefix the final Data with the compression methods/process e.g. "bbpf_XX_YY"
        'bbpf::end' => proc { |data, _info: {}|
          info['m'].to_s + namedelim_ + 'bbpf@' + data
        }, # Special Method which prefix the final Data with the compression methods/process e.g. "bbpf_XX_YY"

        'plain' => proc { |data, _info: {}| data },
        '^nil::' => proc { |_data, _info: {}| nil }
      }
    end

    def decompressmethods
      autoload_declare
      {
        #        'bbpf_xz' => proc { |data| XZ.decompress(data.gsub(%r{^bbpf_xz@}, '')) },
        #       'bbpf_xz_base64' => proc { |data| XZ.decompress(Base64.decode64(data.gsub(%r{^bbpf_xz_base64@}, ''))) },

        '::shellout' => proc { |data, cmd1 = 'tee', cmd2 = 'tee', cmd3 = 'tee', _info: {}|
          compressmethods['::shellout'].call(data, cmd1, cmd2, cmd3)
        },
        '::error' => proc { |data, error_msg = '', error_msg_prefix = '', error_msg_postfix = '', _info: {}|
                       compressmethods['::error'].call(data, error_msg, error_msg_prefix, error_msg_postfix)
                     },
        '::simulateruntimeerror' => proc { |data, _info: {}|
          # compressmethods['::simulateruntimeerror'].call(data)
          data
        },
        'simulateruntimeerror' => proc { |data, _info: {}|
          # compressmethods['::simulateruntimeerror'].call(data)
          data
        },
        '7z::xz::shellout' => proc { |data, _info: {}|
                                compressmethods['::shellout'].call(data, '7za -txz -an -si -so     x', 'tee')
                              },
        '7z::gzip::shellout' => proc { |data, _info: {}|
                                  compressmethods['::shellout'].call(data, '7za -tgzip -an -si -so     x', 'tee')
                                },
        '7z::bzip2::shellout' => proc { |data, _info: {}|
                                   compressmethods['::shellout'].call(data, '7za -tbzip2 -an -si -so     x', 'tee')
                                 },
        '7z::zip::shellout' => proc { |data, _info: {}|
                                 compressmethods['::shellout'].call(data, '7za -tzip -an -si -so     x', 'tee')
                               },
        '7z::shellout' => proc { |data, _info: {}|
                            compressmethods['::shellout'].call(data, '7za -txz -an -si -so     x', 'tee')
                          },
        '7z::' => proc { |data, _info: {}|
                    dfile = StringIO.new(data)
                    data = nil
                    SevenZipRuby::Reader.open(dfile) do |szr|
                      smallest_file = szr.entries.select(&:file?).min_by(&:size) ### There should be only 1 file.. So no worry..
                      data = szr.extract_data(smallest_file)
                    end
                    data
                  },

        'gz::simplecompress' => proc { |data, _info: {}| SimpleCompress.expand(data) },
        'gz::zlibgzip' => proc { |data, _info: {}|
          buf = StringIO.new(data)
          z = Zlib::GzipReader.new(buf)
          z.read
        },
        'gz::zlib' => proc { |data, _info: {}| Zlib::Inflate.inflate(data) },
        'gz' => proc { |data, _info: {}| decompressmethods['gz::zlibgzip'].call(data) },

        'xz' => proc { |data, _info: {}| XZ.decompress(data) },

        'bz2::ffi' => proc { |data, _info: {}|
          bz2  = RBzip2::FFI::Decompressor.new(StringIO.new(data)) # wrap the file into the decompressor
          data = bz2.read
          bz2.close
          data
        },
        'bz2::java' => proc { |data, _info: {}|
          bz2  = RBzip2::Java::Decompressor.new(StringIO.new(data)) # wrap the file into the decompressor
          data = bz2.read
          bz2.close
          data
        },
        'bz2::ruby' => proc { |data, _info: {}|
          bz2  = RBzip2::Ruby::Decompressor.new(StringIO.new(data)) # wrap the file into the decompressor
          data = bz2.read
          bz2.close
          data
        },
        'bz2::auto' => proc { |data, _info: {}|
          bz2  = RBzip2.default_adapter::Decompressor.new(StringIO.new(data)) # wrap the file into the decompressor
          data = bz2.read
          bz2.close
          data
        },

        'bz2::cmd' => proc { |data, _info: {}|
                        compressmethods['::shellout'].call(data, 'bzip2 -d --best -s -qc ', 'tee')
                      },

        'bzip2' => proc { |data, _info: {}|
          data = Bzip2::FFI::Reader.read(StringIO.new(data))
          data
        },

       'bz2' => proc { |data, _info: {}|
         begin
           decompressmethods['bzip2'].call(data)
         rescue NameError, LoadError, Bzip2::FFI::Error::MagicDataError
           begin
             decompressmethods['bz2::auto'].call(data)
           rescue NameError, LoadError
             decompressmethods['bz2::ruby'].call(data)
           end
         end
       },

       'base64' => proc { |data, _info: {}| Base64.decode64(data) },
       '^json' => proc { |data, _info: {}|
                    begin
                      JSON.parse(data)
                    rescue
                      data
                    end
                  },
       '^yaml' => proc { |data, _info: {}|
                    begin
                      YAML.safe_load(data)
                    rescue
                      data
                    end
                  },
        'bbpf' => proc { |data, _info: {}| # rubocop:disable Lint/UnderscorePrefixedVariableName
          m = data.match(%r{^.+bbpf@})[0]
          data = data.gsub(m, '')
          m = m.gsub(%r{.bbpf@}, '')

          data = decompress(data, m)
          _info['continue'] = false
          data
        }, # Special Method which prefix the final Data with the compression methods/process e.g. "bbpf_XX_YY"
        'bbpf::start' => proc { |data, _info: {}| data }, # Special Method which prefix the final Data with the compression methods/process e.g. "bbpf_XX_YY"
        'bbpf::end' => proc { |data, _info: {}|  data  }, # Special Method which prefix the final Data with the compression methods/process e.g. "bbpf_XX_YY"
        'plain' => proc { |data, _info: {}| data },
        '^nil::' => proc { |_data, _info: {}| nil }
      }
    end

    def decompress_precheck?(methods)
      methods = methods.split(',') if methods.is_a? String
      methods.all? do |method|
        method.split(namedelim_).map { |m| decompressmethods[m] }.all? { |p| !p.nil? }
      end
    end

    def decompress_cleansemethods(decompressmethods_chosen) ## Remove Invalid DecompressMethods
      decompressmethods_chosen = decompressmethods_chosen.split(',') if decompressmethods_chosen.is_a? String

      decompressmethods_chosen.select do |method|
        method.split(namedelim_).map { |m| decompressmethods[m] }.all? { |p| !p.nil? }
      end
    end

    def decompress(data, method)
      methodprocs = method.split(namedelim_).reverse.map { |m| decompressmethods[m] }
      pipeprocess(data, methodprocs, _info: { 'm' => method, 'compress' => false })
    end

    def compress_precheck?(methods)
      methods = methods.split(',') if methods.is_a? String
      methods.all? do |method|
        method.split(namedelim_).map { |m| compressmethods[m] }.all? { |p| !p.nil? }
      end
    end

    def compress_cleansemethods(compressmethods_chosen) ## Remove Invalid CompressMethods
      compressmethods_chosen = compressmethods_chosen.split(',') if compressmethods_chosen.is_a? String

      compressmethods_chosen.select do |method|
        method.split(namedelim_).map { |m| compressmethods[m] }.all? { |p| !p.nil? }
      end
    end

    def compress(data, method)
      methodprocs = method.split(namedelim_).map { |m| compressmethods[m] }
      pipeprocess(data, methodprocs, _info: { 'm' => method, 'compress' => true })
    end

    attr_writer :pipeprocess_stats

    attr_reader :pipeprocess_stats

    def pipeprocess(data, processpipe, _info: {}) # rubocop:disable Lint/UnderscorePrefixedVariableName
      @pipeprocess_stats << data.to_s.length unless @pipeprocess_stats.nil? || data.nil?
      _info['continue'] = true
      processpipe.reduce(data) do |data__, p|
        if _info['continue']
          o = p.call(data__, _info: _info)
          unless @pipeprocess_stats.nil? || data.nil?
            @pipeprocess_stats << if o.nil?
                                    -1
                                  else
                                    o.to_s.length
                                  end
          end
        else
          o = data__
        end
        o
      end
    end

    def testdata
      t = <<-TTTTTDATA
      SOOYEANISTESTINGCOMPRESSFACTWITH THIS STRING=+_` <[{ 'aaaa':'a0/s'}]>|!/?
       @The quick brown fox jumps over the lazy dog's back
       @THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG'S BACK 1234567890@

       @Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
       eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim
       ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut
       aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit
       in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
       Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
       deserunt mollit anim id est laborum.@

       @\#\$#%$@^%$#^%^$&^&%*&*(&^(&^)*&^)*&`\"\\"
         {

         "a" : "",
         "b":null,
         "c":"aaaa"

         }
      TTTTTDATA
      t
    end

    def checkmethod_geterrormsg
      return nil if @checkmethod_errormsg_.nil? || @checkmethod_errormsg_.is_a?(String) && @checkmethod_errormsg_.empty?

      if @checkmethod_errormsg_.is_a?(String) && @checkmethod_errormsg_ == DEFAULT_ERROR_MSG
        @checkmethod_errormsg_
      else
        e = @checkmethod_errormsg_
        errorjson = {}
        errorjson['value'] = DEFAULT_ERROR_MSG
        errorjson['exceptiontype'] = e.class.to_s
        errorjson['message'] =
          "Error during processing: #{$ERROR_INFO}\n" \
          "#{e.message}\n" \
          "Backtrace:\n\t#{e.backtrace.join("\n\t")}"

        JSON.generate(errorjson)
      end
    end

    def checkmethod_seterrormsg(msg = DEFAULT_ERROR_MSG)
      @checkmethod_errormsg_ = msg
    end

    def checkmethod(method, fallback_method = ['plain'])
      autoload_declare
      if fallback_method.is_a? String
        fallback_method = fallback_method.split(',')
        #       fallback_method += ['plain']
      end
      if method.is_a? String
        method = method.split(',')
      end

      method += fallback_method

      method = method.reject { |x| x.nil? || x.empty? }.reduce(nil) do |selectmethod, method2test|
        if selectmethod.nil? || selectmethod.empty?
          begin
            checkmethod_seterrormsg unless method2test == '::error'
            testdataend = decompress(compress(testdata, method2test), method2test) unless %r{::simulate}.match?(method2test)
            # %r{^::}.match?(method2test) Give a pass to internal methods...including the ::error, so we can force for an error in a testing environment
            selectmethod = method2test if testdata == testdataend || %r{::simulate}.match?(method2test) || %r{^::}.match?(method2test) || Regexp.new("#{namedelim}::").match?(method2test)
          rescue LoadError => e
            selectmethod = nil
            checkmethod_seterrormsg(e)
          rescue => e
            selectmethod = nil
            checkmethod_seterrormsg(e)
          end
        end
        selectmethod
      end
      method
    end

    def compressed_factname_info(factname, _compressmethod)
      factname_info = "#{factname}-info"
      factname_info
    end

    def compressed_factname_dump(factname, compressmethod)
      factname_data = "#{factname}-dump#{namedelim}#{compressmethod.tr(namedelim_, namedelim)}"
      factname_data
    end

    def compressed_factnames(factname, compressmethod)
      [ compressed_factname_info(factname, compressmethod), compressed_factname_dump(factname, compressmethod) ]
    end

    def summarise(srcdata, summariseoptions, summarisedversion = {})
      return summarisedversion unless srcdata.is_a?(Hash) || srcdata.is_a?(Array)
      return summarisedversion if  !srcdata.is_a?(Hash) && summariseoptions.is_a?(Hash)
      return summarisedversion if  !srcdata.is_a?(Array) && summariseoptions.is_a?(Array)

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
              summarisedversion[k] = summarise(srcdata[k], v, summarisedversion[k])
            elsif v.is_a?(Array) && !srcdata[k].nil?
              summarisedversion[k] = []
              summarisedversion[k] = summarise(srcdata[k], v, summarisedversion[k])
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
          summarisedversion.push(new_e) unless new_e.nil? || new_e.empty?
        end
      end
      summarisedversion
    end
  end
end

# Module to Help in Resolution when using Bigbigpuppetfacter for setting Compression Method.
module Facter::Util::Bigbigpuppetfacter
  def compressmethod_used
    @compressmethod
  end

  def use_compressmethod(compressmethod_chosen)
    return if @compressmethod == compressmethod_chosen

    compressmethod_chosen = Facter::Util::Bigbigpuppetfacts.compress_cleansemethods(compressmethod_chosen) unless compressmethod_chosen.nil?

    Facter::Util::Bigbigpuppetfacts.autoload_declare

    compressmethod_chosen = Facter::Util::Bigbigpuppetfacts.checkmethod(compressmethod_chosen, @compressmethod_fallback)
    @compressmethod = compressmethod_chosen
  end

  def use_compressmethod_fallback(compressmethod_chosen = nil)
    compressmethod_chosen = Facter::Util::Bigbigpuppetfacts.compress_cleansemethods(compressmethod_chosen) unless compressmethod_chosen.nil?

    @compressmethod_fallback = if compressmethod_chosen.nil?
                                 if block_given? # Use the Block if no compressmethod_chosen is given, while block is.
                                   '{yield}'
                                 else # no block and parameter...... then reset the original behaviour.
                                   '^nil::'
                                 end # fallback is valid or not based on compress_precheck?
                               elsif Facter::Util::Bigbigpuppetfacts.compress_precheck?(compressmethod_chosen)
                                 compressmethod_chosen
                               else
                                 '^nil::'
                               end

    @compressmethod_fallback_proc = if @compressmethod_fallback == '{yield}'
                                      proc { yield }
                                    else
                                      Facter::Util::Bigbigpuppetfacts.compressmethods[@compressmethod_fallback]
                                    end
  end

  def compress(value, method = 'auto', bypass_shellcommands = nil)
    if block_given?
      yield(method)
    end

    unless bypass_shellcommands.nil? || bypass_shellcommands.empty?
      return Facter::Core::Execution.execute(bypass_shellcommands)
    end

    @compressmethod_fallback = '^nil::' if @compressmethod_fallback.nil? || @compressmethod_fallback.empty?

    method = @compressmethod if method == 'auto' && !@compressmethod.nil?
    method = nil if method == 'auto'

    method = [] if method.nil? || method.empty?
    method = Facter::Util::Bigbigpuppetfacts.checkmethod(method, @compressmethod_fallback)

    if method.nil? && @compressmethod_fallback == '{yield}'
      @compressmethod_fallback_proc.call(value)
    else

      return nil if method.nil?

      if !value.is_a?(String) && !%r{^[\^]}.match?(method)
        method = '^json' + Facter::Util::Bigbigpuppetfacts.namedelim_ + method
      end

      begin
        Facter::Util::Bigbigpuppetfacts.compress(value, method)
      rescue NameError, LoadError => e
        Facter::Util::Bigbigpuppetfacts.checkmethod_seterrormsg(e)
        Facter::Util::Bigbigpuppetfacts.compressmethods['::error'].call(value)
      rescue => e
        Facter::Util::Bigbigpuppetfacts.checkmethod_seterrormsg(e)
        Facter::Util::Bigbigpuppetfacts.compressmethods['::error'].call(value)
      end

    end
  end

  def decompress(_compressed_value, method = 'auto')
    if block_given?
      yield(method)
    end

    @compressmethod_fallback = '^nil::' if @compressmethod_fallback.nil? || @compressmethod_fallback.empty?

    method = @compressmethod if method == 'auto' && !@compressmethod.nil?
    method = nil if method == 'auto'

    method = [] if method.nil? || method.empty?
    method = Facter::Util::Bigbigpuppetfacts.checkmethod(method, @compressmethod_fallback)

    return nil if method.nil?

    begin
      Facter::Util::Bigbigpuppetfacts.decompress(value, method)
    rescue NameError, LoadError => e
      Facter::Util::Bigbigpuppetfacts.checkmethod_seterrormsg(e)
      Facter::Util::Bigbigpuppetfacts.decompressmethods['::error'].call(value)
    rescue => e
      Facter::Util::Bigbigpuppetfacts.checkmethod_seterrormsg(e)
      Facter::Util::Bigbigpuppetfacts.decompressmethods['::error'].call(value)
    end
  end
end
Facter::Util::Resolution.include Facter::Util::Bigbigpuppetfacter
Facter::Core::Aggregate.include Facter::Util::Bigbigpuppetfacter

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
