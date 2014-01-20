require 'rubygems'
require 'google_drive'
require_relative 'pdf_helper'
require_relative 'text_cover_sheet'
require 'csv'

module AddressEvaluation
  class AddressList
    include Enumerable

    def initialize
      @session = GoogleDrive.login(ENV['COA_SCANS_NAME'],ENV['COA_SCANS_PASSWORD'])
      @spreadsheet = @session.collection_by_title('sewer laterals').file_by_title('avalon addresses')
    end

    def each
      @spreadsheet.worksheets[0].list.each {|row| yield "#{row['Num']} #{row['Street']}" unless row['Num'].empty? || row['Street'].empty?}
    end
  end
end

def get_addresses
  addresses_filename = '/Users/palfvin/avlats/tmp/addresses.csv'
  if File.exists?(addresses_filename)
    addresses = CSV.read(addresses_filename).flatten
  else
    addresses = AddressEvaluation::AddressList.new.to_a.uniq
    CSV.open(addresses_filename, 'wb') do |csv|
      addresses.each { |addr| csv << [addr] }
    end
  end
  addresses
end

def get_cover_sheets
  addresses_covers_filename = '/Users/palfvin/avlats/tmp/addresses.pdf'
  unless File.exists?(addresses_covers_filename)
    PDFHelper.merge_pdf_files(get_addresses.collect {|addr| DefaultCoverSheet.write_pdf(addr)}, addresses_covers_filename)
  end
  addresses_covers_filename
end

def get_ocr_addresses
  ocr_addresses_filename = '/Users/palfvin/avlats/tmp/ocr_addresses.txt'
  if File.exists?(ocr_addresses_filename)
    ocr_addresses = IO.read(ocr_addresses_filename).split("\n")
  else
    ocr_addresses = PDFHelper.ocr_pdf(get_cover_sheets).map { |text| CoverSheet.text_from_cover(text) }
    File.write(ocr_addresses_filename, ocr_addresses.join("\n"))
  end
  ocr_addresses
end

addresses = get_addresses
ocr_addresses = get_ocr_addresses

capitalized_addresses = addresses.map { |addr| addr.upcase }

capitalized_addresses.each_with_index do |addr, i|
  if ocr_addresses[i] != addr
    puts "ocr ##{i} = #{ocr_addresses[i]} vs. expected #{addr}"
  end
end





