require_relative '../bbpfdrivers.rb'

# Drivers to Load the Z7Z method
class BBPFDrivers::Z7Z
  def initialise; end

  def compressmethods
    {
      # 7z, zip, gzip, bzip2 or tar. 7z xz
      '7z::xz::shellout2' => proc { |data, _info: {}|
                               compressmethods['::shellout2'].call(data, '7za -txz -an    -so     a  <TMPFILE>.tmp <TMPFILE> ', 'tee')
                             },
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
                }
    }
  end

  def decompressmethods
    {
      '7z::xz::shellout2' => proc { |data, _info: {}|
                              compressmethods['::shellout2'].call(data, '7za -txz -an -si -so     x <TMPFILE>', 'tee')
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
    lib_path = File.join(File.dirname(__FILE__), './seven_zip_ruby-1.3.0/lib/')
    $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

    autoload :SevenZipRuby, 'seven_zip_ruby'
  end
end
