require 'spec_helper'

describe "sheet processor" do
  let(:page_identifiers) {['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen'].collect(&:upcase)}
  let(:doc_length) {14}
  let(:cover_indexes) {[0,3,5,9,10]}
  let(:base_page_text) {chars = ('A'..'Z').to_a ; 8.times.collect {chars[rand(chars.length)]}.join }
  let(:doc_sheets) do 
    sheets = Array.new(doc_length)
    cover_indexes.each {|c| sheets[c] = CoverSheet.cover_from_text(page_identifiers[c])}
    sheets.each_with_index {|sheet, i| sheets[i] = base_page_text+page_identifiers[i] unless sheet}
    sheets
  end
  let(:sets) {[[0, 1..2], [3,4..4], [5, 6..8],[9,nil],[10, 11..13]]}

  it "should process sheets with test doubles" do
    pdf_filename = "mytemp_pdf"
    pdf_helper = double("pdf_helper")
    set_proc = -> {}
    allow(DefaultCoverSheet).to receive(:decode_pdf).and_return(doc_sheets)
    sets.each do |index, range|
      dummy_pdf = range ? "#{range}.pdf" : nil
      expect(pdf_helper).to receive(:extract_pdf).with(pdf_filename, range).and_return(dummy_pdf) if range
      expect(set_proc).to receive(:call).with(CoverSheet.text_from_cover(doc_sheets[index]), dummy_pdf)
    end
    CoverSheetedDoc.new(pdf_filename, pdf_helper).process_sets(&set_proc)
  end


  it "should process sheets and pull the right pages by OCR validation" do
    normalize = -> (text) {CoverSheet.normalize_cover_text(text)}
    tempfiles = [] # To keep garbage collector from deleting the files
    page_text = -> (i) {
      binding.pry if i.nil?
      base_page_text+page_identifiers[i]}
    page_pdfs = doc_sheets.each_with_index.map do |text, i|
      text ||= page_text.(i)
      tempfiles << pdf_file = CoverSheet.tmpfile('.pdf', 'page')
      DefaultCoverSheet.write_pdf(text, pdf_file, -> (t) {t})  # No special cover test
      pdf_file
    end
    tempfiles << doc_pdf = CoverSheet.tmpfile('.pdf', 'doc')
    PDFHelper.merge_pdf_files(page_pdfs, doc_pdf)
    set_proc = lambda do |text, pdf|
      set = sets.shift
      CoverSheet.normalized_eql(text, CoverSheet.text_from_cover(doc_sheets[set[0]]))
      if set[1]
        decode_results = DefaultCoverSheet.decode_pdf(pdf, normalize: true)
        expected_results = set[1].map {|i| page_text.(i)}
        binding.pry unless pdf && decode_results == expected_results
        expect(decode_results).to eql(expected_results)
      else expect(pdf).to be nil
      end
    end
    expect(set_proc).to receive(:call).exactly(cover_indexes.length).times.and_call_original
    CoverSheetedDoc.new(doc_pdf, PDFHelper).process_sets(&set_proc)
  end

end