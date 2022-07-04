require_relative '../bbpfdrivers.rb'

# Drivers to Load the XZ method
class BBPFDrivers::XZ
  def initialise; end

  def compressmethods
    {
      'xz' => proc { |data, _info: {}| XZ.compress(data) }
    }
  end

  def decompressmethods
    {
      'xz' => proc { |data, _info: {}| XZ.decompress(data) }
    }
  end

  alias encodemethods compressmethods

  alias decodemethods decompressmethods

  def test_methods
    {
      'xz' => proc { |data, _info: {}| # rubocop:disable Lint/UnderscorePrefixedVariableName
      decompressmethods['xz'].call(
        compressmethods['xz'].call(data, _info: _info), _info: _info
      )
      }
    }
  end

  def autoload_declare
    lib_path = File.join(File.dirname(__FILE__), '../../../facter/util/ruby-xz-1.0.0/lib/')
    $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

    autoload :XZ, 'xz'
  end
end
