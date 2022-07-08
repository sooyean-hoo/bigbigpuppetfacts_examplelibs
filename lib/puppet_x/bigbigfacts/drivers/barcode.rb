require_relative '../bbpfdrivers.rb'

# Drivers to Load the BARCODE method
class BBPFDrivers::BARCODE
  def initialise; end

  def compressmethods
    {
      'barcode' => proc { |data, _info: {}|
        barcode = Barby::Code39.new(data, true)
        barcode.to_ascii
      }
    }
  end

  def decompressmethods
    {
      'barcode' => proc { |data, _info: {}| data }
    }
  end

  alias encodemethods compressmethods

  alias decodemethods decompressmethods

  def test_methods
    {
      'barcode' => proc { |data, _info: {}|
        #        decompressmethods['xz'].call(
        #          compressmethods['xz'].call(data, _info: _info), _info: _info
        #        )
        data # Disabled it... For QR Code, there is not such thing as inverse function. So This test is disabled by just return the input.
      }
    }
  end

  def autoload_declare
    lib_path = File.join(File.dirname(__FILE__), '../../../facter/util/barby-0.6.8/lib/')
    $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

    autoload :Barby, 'barby'

    skipclasses = ['DataMatrix', 'QrCode', 'Pdf417', 'directly']
    @barcodeparts ||= Facter::Util::Bigbigpuppetfacts.loaddrivers([ File.join(File.dirname(__FILE__), '../../../facter/util/barby-0.6.8/lib/barby/barcode/*.rb') ],
opts: { loadonly: true, skipclasses: skipclasses })
    #    require 'barby/barcode/bookland'
    #    require 'barby/barcode/codabar'
    #    require 'barby/barcode/code_128'
    #    require 'barby/barcode/code_25'
    #    require 'barby/barcode/code_25_iata'
    #    require 'barby/barcode/code_25_interleaved'
    #    require 'barby/barcode/code_39'
    #    require 'barby/barcode/code_93'
    #    require 'barby/barcode/ean_13'
    #    require 'barby/barcode/ean_8'
    #    require 'barby/barcode/gs1_128'
    #    require 'barby/barcode/upc_supplemental'
    #    require 'barby/barcode/pdf_417'
    #    require 'barby/barcode/qr_code'
    #    require 'barby/barcode/data_matrix'

    skipclasses = ['CairoOutputter', 'HtmlOutputter', 'PDFWriterOutputter', 'PngOutputter', 'PrawnOutputter', 'RmagickOutputter', 'SvgOutputter']
    @barcodeouts ||= Facter::Util::Bigbigpuppetfacts.loaddrivers([File.join(File.dirname(__FILE__), '../../../facter/util/barby-0.6.8/lib/barby/outputter/*.rb')],
opts: { loadonly: true, skipclasses: skipclasses })
    #    require 'barby/outputter/ascii_outputter'
    #    require 'barby/outputter/cairo_outputter'
    #    require 'barby/outputter/html_outputter'
    #    require 'barby/outputter/pdfwriter_outputter'
    #    require 'barby/outputter/png_outputter'
    #    require 'barby/outputter/prawn_outputter'
    #    require 'barby/outputter/rmagick_outputter'
    #    require 'barby/outputter/svg_outputter'
  end
end
