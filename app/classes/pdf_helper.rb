require 'RMagick'
require 'pry'
require 'tmpdir'

class PDFHelper

  class << self

  def convert ; '/usr/local/bin/convert' ; end

  def pdftk ; '/usr/local/bin/pdftk' ; end

  def gs ; '/opt/local/bin/gs' ; end

  def exec_command(command)
    command = command.join(' ') if command.kind_of?(Array)
    binding.pry unless result = Kernel.system(command)
    result
  end

  def convert_tiff_to_pdf(tiff_filename, pdf_filename = CoverSheet.tmpfile('.pdf'))
    exec_command([convert, tiff_filename, pdf_filename])
    pdf_filename
  end

  def convert_pdf_to_single_tiff(pdf_filename, tiff_filename = CoverSheet.tmpfile('.tiff'))
    exec_command([convert, pdf_filename, '-monochrome -compress Group4', tiff_filename])
    tiff_filename
  end

  def convert_pdf_to_png(pdf_filename, png_filename, rotation = 0)  # rotation doesn't work!!!
    options = "-dSAFER -dBATCH -dNOPAUSE -r200 -sDEVICE=pngmono -dAutoRotatePages=/None"
    code = %Q(-c "<</Orientation 2>>" setpagedevice #{rotation} rotate)
    exec_command([gs, options, "-sOutputFile=#{png_filename}", code, "-f #{pdf_filename}"])
    png_filename
  end

  def convert_png_to_rotated_png(input_png, output_png, rotation)
    Magick::Image.read(input_png)[0].rotate(rotation).write(output_png)
  end

  def merge_pdf_files(input_files, output_file = CoverSheet.tmpfile('.pdf'))
    command = (["gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=#{output_file}"]+input_files)
    exec_command(command)
    output_file
  end

  def burst_pdf_file(pdf_filename, output_dir = nil)
    output_dir ||= Dir.mktmpdir
    output = File.join(output_dir, 'page%04d.pdf')
    command = [pdftk, pdf_filename, 'burst output', output].join(' ')
    exec_command(command)
    Dir.glob(File.join(output_dir,'page[0-9][0-9][0-9][0-9].pdf'))
  end

  def extract_pdf(pdf_filename, range)
    range_text = "#{range.begin+1}-#{range.max+1}"
    output_filename = CoverSheet.tmpfile('.pdf', 'segment')
    command = [pdftk, pdf_filename, 'cat', range_text, 'output', output_filename]
    exec_command(command)
    output_filename
  end

  end

end


