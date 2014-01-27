class CoverSheetedDoc

  attr_reader :sheets, :sets

  def initialize(filename, pdf_helper = PDFHelper, cover_sheet_pattern = CoverSheet.default_recognizer)
    @filename = filename
    @cover_sheet_pattern = cover_sheet_pattern
    @pdf_helper = pdf_helper
    @sheets = DefaultCoverSheet.decode_pdf(filename, normalize: false)
    calc_sets
  end

  def process_sets(&set_proc)
    binding.pry if @sets.nil?
    @sets.each do |text, range|
      set_pdf = range ? @pdf_helper.extract_pdf(@filename, range) : nil
      puts "Text is: #{text}"
      set_proc.(CoverSheet.text_from_cover(text, @cover_sheet_pattern), set_pdf)
    end
  end

  private

  def calc_sets
    return unless sheets[0]
    cover_indexes = sheets.each_with_index.collect {|s, i| i if s && @cover_sheet_pattern =~ s.delete(' _')}
    (cover_indexes << sheets.length).compact!
    calc_sets_from_cover_indexes(cover_indexes)
  end

  def calc_sets_from_cover_indexes(cover_indexes)
    @sets = []
    cover_indexes[0...-1].each_with_index.collect do |c, i|
      range = c+1..cover_indexes[i+1]-1
      range = nil if range.size == 0
      @sets << [sheets[c], range]
    end
  end

end


