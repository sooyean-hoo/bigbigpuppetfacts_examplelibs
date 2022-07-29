require_relative '../bbpfdrivers.rb'

# Drivers to Load the XZ method
class BBPFDrivers::XZCMD
  def initialise; end

  def compressmethods
    {
      'xz::cmd' => proc { |data, _info: {}| # rubocop:disable Lint/UnderscorePrefixedVariableName
                     _info['PATH'] = '/usr/local/bin/:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
                     Facter::Util::Bigbigpuppetfacts.compressmethods['::cmd'].call(data, ' tee | xz -z -c | tee ', _info: _info)
                   },
    }
  end

  def decompressmethods
    {
      'xz::cmd' => proc { |data, _info: {}| # rubocop:disable Lint/UnderscorePrefixedVariableName
                     _info['PATH'] = '/usr/local/bin/:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
                     Facter::Util::Bigbigpuppetfacts.decompressmethods['::cmd'].call(data, ' tee | xz -d -c | tee ', _info: _info)
                   },
    }
  end

  alias encodemethods compressmethods

  alias decodemethods decompressmethods

  def test_methods
    {
      ### The rest of the default Just use the Default tests.
    }
  end

  def autoload_declare
    # For excluding from bbpf_supportmatrix's autotest
    # bbpf_supportmatrix_noautotest = []
    # bbpf_supportmatrix_noautotest << 'xz'
    # bbpf_supportmatrix_noautotest
  end
end
