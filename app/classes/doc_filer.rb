class DocFiler

  def initialize(name, password, filer = GoogleDrive)
    @session = filer.login(name, password)
    change_working_collection_to_root
  end

  def interpret_pdf(filename)
    ipdf = CoverSheetedDoc.new(filename)
    ipdf.process_sets do |cover_text, pdf_filename|
      @pdf_filename = pdf_filename
      process_command(cover_text)
    end
  end

  def folder(path)
    change_working_collection_to_root if %r(^/) =~ path
    collection_list = path.split('/')
    collection_list.each {|collection| change_working_collection(collection)}
  end

  def file(filename)
    remote_file = @session.upload_from_file(@pdf_filename, filename+'.pdf')
    @collection.add(remote_file)
    puts "Stored file #{@pdf_filename} in #{filename}"
  end

  private

  def process_command(command)
    puts "Command is: #{command}"
    eval(command.downcase)
  end

  def change_working_collection_to_root
    @collection = @session.root_collection
    change_working_collection('Scans')
  end

  def change_working_collection(collection)
    @collection = @collection.subcollection_by_title(collection) unless collection.empty?
    raise "Can't change to (#{collection})" unless @collection
    puts "Moving to #{collection}"
  end

end

