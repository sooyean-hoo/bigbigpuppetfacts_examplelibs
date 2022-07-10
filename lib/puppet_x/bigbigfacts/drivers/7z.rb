require_relative '../bbpfdrivers.rb'
require 'erb'
# Drivers to Load the Z7Z method
class BBPFDrivers::Z7Z
  def initialise; end

  def compressmethods
    erbtemplate_shellout2 = ['7za -t<%=ext%> a  <TMPFILE>.<%=ext%> <TMPDIR>/data.dat ', '<TMPFILE>.<%=ext%>']

    {
      # 7z, zip, gzip, bzip2 or tar. 7z xz
      '7z::xz::shellout2' => proc { |data, _info: {}|
                               ext = 'xz'
                               Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, (ERB.new(erbtemplate_shellout2[0])).result(binding),
  (ERB.new(erbtemplate_shellout2[1])).result(binding))
                             },
                             '7z::gzip::shellout2' => proc { |data, _info: {}|
                                                        ext = 'gzip'
                                                        Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, (ERB.new(erbtemplate_shellout2[0])).result(binding),
                           (ERB.new(erbtemplate_shellout2[1])).result(binding))
                                                      },
                           '7z::bzip2::shellout2' => proc { |data, _info: {}|
                                                       ext = 'bzip2'
                                                       Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, (ERB.new(erbtemplate_shellout2[0])).result(binding),
                           (ERB.new(erbtemplate_shellout2[1])).result(binding))
                                                     },
                          '7z::zip::shellout2' => proc { |data, _info: {}|
                                                    ext = 'zip'
                                                    Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, (ERB.new(erbtemplate_shellout2[0])).result(binding),
                          (ERB.new(erbtemplate_shellout2[1])).result(binding))
                                                  },

      '7z::xz::shellout' => proc { |data, _info: {}|
                              Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -txz        a', 'tee')
                            },
      '7z::gzip::shellout' => proc { |data, _info: {}|
                                Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -tgzip         a', 'tee')
                              },
      '7z::bzip2::shellout' => proc { |data, _info: {}|
                                 Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -tbzip2         a', 'tee')
                               },
      '7z::zip::shellout' => proc { |data, _info: {}|
                               Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -tzip         a', 'tee')
                             },
      '7z::shellout' => proc { |data, _info: {}|
                          Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -txz       a', 'tee')
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
    erbtemplate_shellout2 = [
      ['7za -t<%=ext%>        x <TMPDIR>/data.dat -o<TMPDIR2>', '<TMPDIR2>/data'],
      ['7za -t<%=ext%>        x <TMPDIR>/data.dat -o<TMPDIR2>', '<TMPDIR2>/data.dat'],
    ]
    {
      '7z::xz::shellout2' => proc { |data, _info: {}|
                               ext = 'xz'
                               Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, (ERB.new(erbtemplate_shellout2[0][0])).result(binding),
(ERB.new(erbtemplate_shellout2[0][1])).result(binding))
                             },
      '7z::gzip::shellout2' => proc { |data, _info: {}|
                                 ext = 'gzip'
                                 Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, (ERB.new(erbtemplate_shellout2[1][0])).result(binding),
(ERB.new(erbtemplate_shellout2[1][1])).result(binding))
                               },
                               '7z::bzip2::shellout2' => proc { |data, _info: {}|
                                                           ext = 'bzip2'
                                                           Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, (ERB.new(erbtemplate_shellout2[0][0])).result(binding),
                               (ERB.new(erbtemplate_shellout2[0][1])).result(binding))
                                                         },
                          '7z::zip::shellout2' => proc { |data, _info: {}|
                                                    ext = 'zip'
                                                    Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, (ERB.new(erbtemplate_shellout2[1][0])).result(binding),
                          (ERB.new(erbtemplate_shellout2[1][1])).result(binding))
                                                  },

      '7z::xz::shellout' => proc { |data, _info: {}|
                              Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -txz        x', 'tee')
                            },
      '7z::gzip::shellout' => proc { |data, _info: {}|
                                Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -tgzip        x', 'tee')
                              },
      '7z::bzip2::shellout' => proc { |data, _info: {}|
                                 Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -tbzip2         x', 'tee')
                               },
      '7z::zip::shellout' => proc { |data, _info: {}|
                               Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -tzip        x', 'tee')
                             },
      '7z::shellout' => proc { |data, _info: {}|
                          Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout'].call(data, '7za -txz        x', 'tee')
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

  # rubocop:enable Style/ClassAndModuleChildren
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
