require_relative '../bbpfdrivers.rb'

# Drivers to Load the Bzip2 method
class BBPFDrivers::BZIP2
  def initialise; end

  def compressmethods
    {
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
               }
    }
  end

  def decompressmethods
    {
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
     }
    }
  end

  def test_methods
    {
      # Empty, so use the default one.
      #        'bz2' => proc { |data, info: {}|
      #          decompressmethods_proc['bz2'].call(
      #          compressmethods_proc['bz2'].call(data, info: info), info: info
      #        )
      #        }
    }
  end

  alias encodemethods compressmethods
  alias decodemethods decompressmethods

  def autoload_declare
    lib_path = File.join(File.dirname(__FILE__), '../../../facter/util/bzip2-ffi-1.1.0/lib/')
    $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

    lib_path = File.join(File.dirname(__FILE__), '../../../facter/util/rbzip2-0.3.0/lib/')
    $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

    autoload :RBzip2, 'rbzip2'
    autoload :Bzip2, 'bzip2/ffi'
  end
end
