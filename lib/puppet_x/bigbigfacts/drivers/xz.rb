module BBPF::Drivers
# Drivers to Load the XZ method
  class XZ
    def initialise; end

    def compressmethods_proc
      {
        'xz' => proc { |data, _info: {}| XZ.compress(data) }
      }
    end

    def decompressmethods_proc
      {
        'xz' => proc { |data, _info: {}| XZ.decompress(data) }
      }
    end

    def test_decomp_comp
      {
        'xz' => proc { |data, info: {}|
          decompressmethods_proc['xz'].call(
          compressmethods_proc['xz'].call(data, info: info), info: info
        )
        }
      }
    end

    def autoload_declare_proc
      lib_path = File.join(File.dirname(__FILE__), '../../../facter/util/ruby-xz-1.0.0/lib/')
      $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

      autoload :XZ, 'xz'
    end
  end
end
