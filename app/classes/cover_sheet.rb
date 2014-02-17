class CoverSheet

  DEFAULT_RECOGNIZER = /^COVER:\s*(.*?)\s*\Z/m

  DEFAULT_FORMATTER = -> (text) {"COVER:\n#{text.upcase}"}

  NULL_FORMATTER = -> (text) {text}

  NULL_RECOGNIZER = /(.*)/m

  @@mutex = Mutex.new

  class << self

  def default_recognizer ; DEFAULT_RECOGNIZER ; end

  def text_from_cover(text, pattern = DEFAULT_RECOGNIZER)
    pattern =~ text
    $1
  end

  def cover_from_text(text, formatter = DEFAULT_FORMATTER)
    formatter[text]
  end

  def normalize_cover_text(text)
    text.strip.gsub(/ |"|$/,'')
  end

  def normalized_eql(text1, text2)
    binding.pry unless result = normalize_cover_text(text1) == normalize_cover_text(text2)
    result
  end

  def tmpfile(ext = "", base = "")
    file = Tempfile.new([base, ext])
    filename = file.path
    file.close
    @@mutex.synchronize do
      $temp_files ||= []
      $temp_files << file
    end
    filename
  end

  def decode_pdf(pdf_filename, pagesize_threshold: 10000, normalize: false)
    pdf_filenames = PDFHelper.burst_pdf_file(pdf_filename)
    pdf_filenames.map do |pdf_filename|
      decode_pdf_page(pdf_filename) if File.size(pdf_filename) < pagesize_threshold
    end
  end

  def decode_pdf_page(pdf_filename, normalize: false)
    decode_tiff_page(PDFHelper.convert_pdf_to_single_tiff(pdf_filename, tmpfile('.tiff')), normalize)
  end

  def decode_tiff_page(tiff_filename, normalize: false)
    decode_pdf_page(PDFHelper.convert_tiff_to_pdf(tiff_filename, tmpfile('.pdf')), normalize: normalize)
  end

  alias_method :ocr_tiff, :decode_tiff_page
  alias_method :ocr_pdf, :decode_pdf

  def write_tiff(text, filename = tmpfile('.tiff'), customize = DEFAULT_FORMATTER)
    self.write_pdf(text, pdf_filename = tmpfile('.pdf'), customize)
    PDFHelper.convert_pdf_to_single_tiff(pdf_filename, filename)
    filename
  end

  def write_pdf(text, filename = tmpfile('.pdf'), customize = DEFAULT_FORMATTER)
    self.write_tiff(text, tiff_filename = tmpfile('.tiff'), customize)
    PDFHelper.convert_tiff_to_pdf(tiff_filename, filename)
    filename
  end

end ; end

