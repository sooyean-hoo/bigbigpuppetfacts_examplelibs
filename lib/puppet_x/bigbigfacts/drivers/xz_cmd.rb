require_relative '../bbpfdrivers.rb'

# Drivers to Load the XZ method
class BBPFDrivers::XZCMD
  def initialise; end

  def compressmethods
    {
      'xz::cmd' => proc { |data, _info: {}| # rubocop:disable Lint/UnderscorePrefixedVariableName
                     _info['PATH'] = '/usr/local/bin/:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
                     Facter::Util::Bigbigpuppetfacts.compressmethods['::shellout2'].call(data, 'xz -9 <TMPDIR>/data.dat', '<TMPDIR>/data.dat.xz', _info: _info)
                   },
    }
  end

  def decompressmethods
    {
      'xz::cmd' => proc { |data, _info: {}| # rubocop:disable Lint/UnderscorePrefixedVariableName
                     _info['PATH'] = '/usr/local/bin/:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
                     Facter::Util::Bigbigpuppetfacts.decompressmethods['::shellout2'].call(data, 'cp <TMPDIR>/data.dat <TMPDIR>/data.dat1.xz && xz -d <TMPDIR>/data.dat1.xz', '<TMPDIR>/data.dat1', _info: _info)
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
