require 'RMagick'
require 'pry'
require 'tmpdir'

class PDFHelper

  class << self

  def convert ; '/usr/local/bin/convert' ; end

  def pdftk ; '/usr/local/bin/pdftk' ; end

  def tesseract ; '/usr/local/bin/tesseract' ; end

  def exec_command(command)
    command = command.join(' ') if command.kind_of?(Array)
    puts command
    binding.pry unless result = Kernel.system(command)
    result
  end

  def ocr_tiff(tiff_filename, normalize: false)
    text_file_basename = CoverSheet.tmpfile('', 'ocrtext')
    binding.pry unless exec_command([tesseract, tiff_filename, text_file_basename, 'alphanumeric', '2> /dev/null'])
    text = File.read(text_file_basename+'.txt')
    normalize ? CoverSheet.normalize_cover_text(text) : text
  end

  def convert_tiff_to_pdf(tiff_filename, pdf_filename)
    exec_command([convert, tiff_filename, pdf_filename])
  end

  def convert_pdf_to_single_tiff(pdf_filename, tiff_filename)
    exec_command([convert, pdf_filename, '-monochrome -compress Group4', tiff_filename])
  end

  def merge_pdf_files(input_files, output_file = CoverSheet.tmpfile('.pdf'))
    command = (["gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=#{output_file}"]+input_files)
    exec_command(command)
    output_file
  end

  def ocr_pdf(pdf_filename, ocr_filesize_threshold: 2000, normalize: false)
    pdf_filenames = burst_pdf_file(pdf_filename)
    pdf_filenames.each_with_index.map do |pdf_filename, i|
      tiff_filename = CoverSheet.tmpfile('.tiff', 'page')
      puts tiff_filename
      convert_pdf_to_single_tiff(pdf_filename, tiff_filename)
      if File.size?(tiff_filename) < ocr_filesize_threshold
        text = ocr_tiff(tiff_filename)
        binding.pry if !text || text.empty?
        text = CoverSheet.normalize_cover_text(text) if normalize
        text
      end
    end
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


