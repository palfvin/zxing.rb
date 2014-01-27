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

  module AddressEvaluator

    SelectedCoverSheet = QRCoverSheet

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
      addresses[address_subset]
    end

    def address_subset ; (0..-1) ; end

    def get_cover_sheets
      addresses_covers_filename = '/Users/palfvin/avlats/tmp/addresses.pdf'
      unless File.exists?(addresses_covers_filename)
        PDFHelper.merge_pdf_files(get_addresses.collect {|addr| puts addr; SelectedCoverSheet.write_pdf(addr)}, addresses_covers_filename)
      end
      addresses_covers_filename
    end

    ALWAYS_DECODE = true

    def get_decoded_addresses
      decoded_addresses_filename = '/Users/palfvin/avlats/tmp/decoded_addresses.txt'
      if File.exists?(decoded_addresses_filename) && !ALWAYS_DECODE
        decoded_addresses = IO.read(decoded_addresses_filename).split("\n")
      else
        decoded_addresses = SelectedCoverSheet.decode_pdf(get_cover_sheets).map { |text| puts text; CoverSheet.text_from_cover(text) }
        File.write(decoded_addresses_filename, decoded_addresses.join("\n"))
      end
      decoded_addresses
    end

    def evaluate_addresses

      addresses = get_addresses
      decoded_addresses = get_decoded_addresses

      capitalized_addresses = addresses.map { |addr| addr.upcase }

      differences = capitalized_addresses.each_with_index.collect do |addr, i|
        if decoded_addresses[i] != addr
          "decode ##{i} = #{decoded_addresses[i]} vs. expected #{addr}"
        end
      end.compact
      puts (differences.empty? ? "No differences found" : differences)
    end
  end
end




