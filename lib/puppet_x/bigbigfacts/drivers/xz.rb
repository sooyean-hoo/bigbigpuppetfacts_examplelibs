require_relative '../bbpfdrivers.rb'

# Drivers to Load the XZ method
class BBPFDrivers::XZ
  def initialise; end

  def compressmethods
    {
      'xz::simple' => proc { |data, _info: {}| XZ.compress(data) },
      'xz::shellout2' => proc { |data, _info: {}|
                           Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, 'xz ')
                         },

      'xz' => proc { |data, _info: {}|
                begin
                  compressmethods['xz::simple'].call(data)
                rescue NameError, LoadError
                  compressmethods['xz::shellout2'].call(data)
                end
              }
    }
  end

  def decompressmethods
    {
      'xz::simple' => proc { |data, _info: {}| XZ.decompress(data) },
      'xz::shellout2' => proc { |data, _info: {}|
                           Facter::Util::Bigbigpuppetfacts.decompressmethods['::shellout2'].call(data, 'xz -d ')
                         },

      'xz' => proc { |data, _info: {}|
                begin
                  decompressmethods['xz::simple'].call(data)
                rescue NameError, LoadError
                  decompressmethods['xz::shellout2'].call(data)
                end
              }
    }
  end

  alias encodemethods compressmethods

  alias decodemethods decompressmethods

  def test_methods
    {
      'xz::simple' => proc { |data, _info: {}| # rubocop:disable Lint/UnderscorePrefixedVariableName
        decompressmethods['xz::simple'].call(
          compressmethods['xz::simple'].call(data, _info: _info), _info: _info
        )
      }
      ### The rest of the default Just use the Default tests.
    }
  end

  def autoload_declare
    lib_path = File.join(File.dirname(__FILE__), '../../../facter/util/ruby-xz-1.0.0/lib/')
    $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

    autoload :XZ, 'xz'
    # For excluding from bbpf_supportmatrix's autotest
    # bbpf_supportmatrix_noautotest = []
    # bbpf_supportmatrix_noautotest << 'xz'
    # bbpf_supportmatrix_noautotest
  end
end
