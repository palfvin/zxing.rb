require 'spec_helper'

def filename(ext)
  name = "#{Dir.home}/tmp/cover.#{ext}"
  File.delete(name) if File.exists?(name)
  name
end

def drop_txt_suffix(filename)
  filename.sub(/\.txt$/,'')
end

def sample_text ; 'path "Sewer Laterals/Properties"'.upcase ; end

def confirm_tiff_text(filename, text)
  recognized_text = PDFHelper.ocr_tiff(filename, normalize: true)
  cover_text = CoverSheet.cover_from_text(text)
  expect(CoverSheet.normalized_eql(cover_text, recognized_text)).to be_true
end

shared_examples_for "cover sheet" do |cover_sheet|
  describe "cover sheet" do
    it "works for tiff" do
      tiff_filename = filename('tiff')
      cover_sheet.write_tiff(sample_text, tiff_filename)
      confirm_tiff_text(tiff_filename, sample_text)
    end

    it "works for pdf" do
      pdf_filename = filename('pdf')
      tiff_filename = filename('tiff')
      cover_sheet.write_pdf(sample_text, pdf_filename)
      PDFHelper.convert_pdf_to_single_tiff(pdf_filename, tiff_filename)
      confirm_tiff_text(tiff_filename, sample_text)
    end
  end
end

describe "cover sheets" do
  it_behaves_like "cover sheet", OCRCoverSheet
  it_behaves_like "cover sheet", QRCoverSheet
end

