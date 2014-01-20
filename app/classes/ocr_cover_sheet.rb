require 'RMagick'
include Magick

class OCRCoverSheet < CoverSheet ; class << self

  DEFAULT_RECOGNIZER = /^COVER:\s*(.*?)\s*\Z/m

  DEFAULT_FORMATTER = -> (text) {"COVER:\n#{text.upcase}"}

  NULL_FORMATTER = -> (text) {text}

  NULL_RECOGNIZER = /(.*)/m

  def default_recognizer ; DEFAULT_RECOGNIZER ; end

  def write_tiff(text, filename = tmpfile('.tiff'), customize = DEFAULT_FORMATTER)
    image = create_image
    draw_text(image, customize.(text))
    write_image(image, filename)
    filename
  end

  def write_pdf(text, filename = tmpfile('.pdf'), customize = DEFAULT_FORMATTER)
    tiff_filename = filename+'.tiff'
    write_tiff(text, tiff_filename, customize)
    PDFHelper.convert_tiff_to_pdf(tiff_filename, filename)
    File.delete(tiff_filename)
    filename
  end

  private

  def create_image
    Image.new(1700, 200) { self.background_color = "white" }
  end

  def draw_text(image, cover_text)
    text = Draw.new
    text.annotate(image, 0,0,100,100, cover_text) {
      self.density = '200x200'
      self.fill = 'black'
      self.pointsize = 12
      self.font_family = 'Arial'}
  end

  def write_image(image, filename)
    temp_filename = tmpfile
    image.write('tiff:'+temp_filename) { self.colorspace = GRAYColorspace ; self.channel(GrayChannel) }
    remove_alpha_channel(temp_filename, filename)
  end

  def remove_alpha_channel(temp_filename, filename)
    command = "/usr/local/bin/convert #{temp_filename} -alpha off -depth 8 #{filename}"
    Kernel.system(command)
  end

end ; end

