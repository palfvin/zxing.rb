class QRCoverSheet < CoverSheet

  require 'tmpdir'
  require 'peach'
  require 'zxing'

  class << self
    attr_accessor :rotate_on_creation, :rotate_on_read_failure, :resolution, :extent
  end

  self.rotate_on_creation = 0

  self.extent = 144

  self.rotate_on_read_failure = 30

  def self.write_pdf(text, filename = tmpfile('.pdf'), customize = CoverSheet::DEFAULT_FORMATTER)
    prawn = Prawn::Document.new(left_margin: 200)
    prawn.rotate rotate_on_creation do
      prawn.print_qr_code(customize.(text), extent: extent, stroke: false)
    end
    prawn.text(text)
    prawn.render_file(filename)
    filename
  end

  def self.decode_pdf(pdf_filename, pagesize_threshold: 10000, normalize: false)
    dir = Dir.mktmpdir
    output_file_template = File.join(dir, 'page%4d.png')
    PDFHelper.convert_pdf_to_png(pdf_filename, output_file_template)
    Dir.glob(File.join(dir,'page*.png')).map { |f| 
      decode_png_page(f, normalize)}
  end

  def self.decode_pdf_page(pdf_filename, normalize: false)
    PDFHelper.convert_pdf_to_png(pdf_filename, png_filename = tmpfile('.png'))
    decode_png_page(png_filename, normalize)
  end

  private

  def self.decode_png_page(png_filename, normalize)
    text = ZXing.decode(png_filename, rotate_and_retry_on_failure: true)
    normalize ? CoverSheet.normalize_cover_text(text) : text
  end
end