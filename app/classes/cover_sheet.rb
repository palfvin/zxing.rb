class CoverSheet ; class << self

  DEFAULT_RECOGNIZER = /^COVER:\s*(.*?)\s*\Z/m

  DEFAULT_FORMATTER = -> (text) {"COVER:\n#{text.upcase}"}

  NULL_FORMATTER = -> (text) {text}

  NULL_RECOGNIZER = /(.*)/m

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
    normalize_cover_text(text1) == normalize_cover_text(text2)
  end

  def tmpfile(ext = "", base = "")
    file = Tempfile.new([base, ext])
    filename = file.path
    file.close
    $temp_files ||= []
    $temp_files << file
    filename
  end

end ; end

