class TestSetup

  class << self

    def example_path(name, type)
      examples_root+name+'-'+type.capitalize+'.pdf'
    end

    def examples_root ; File.join(Rails.root, 'spec/examples/') ; end

    def repository_properties_path ; "/Sewer Laterals/Properties" ; end

    def folder_cover_path ; example_path('PropertyFolder', 'cover') ; end

    def dummy_property ; "12345 Crescent" ; end

    def dummy_property_path ; File.join(repository_properties_path, dummy_property); end

    def cover_text_for_folder(name)
      %Q(folder "#{name}")
    end

    def cover_text_for_file(name)
      %Q(file "#{name}")
    end

    def example_doc_names ; ['Report','LetterToOwner','CertifiedReceipts','Invoice'] ; end

    def root_folder ; 'scans_test' ; end

    def make_integrated_pdf
      make_cover_sheets
      filenames = make_file_name_list
      PDFHelper.merge_pdf_files(filenames, integrated_pdf_filename)
    end

    def make_file_name_list
      [folder_cover_path]+
        example_doc_names.product(['cover','sample']).map {|names| example_path(*names)}
    end

    def make_cover_sheets
      make_folder_cover_sheet
      make_file_cover_sheets
    end

    def make_file_cover_sheets
      example_doc_names.each do |name|
        cover_path = example_path(name, 'cover')
        DefaultCoverSheet.write_pdf(cover_text_for_file(name), cover_path)
      end
    end

    def make_folder_cover_sheet
      DefaultCoverSheet.write_pdf(cover_text_for_folder(dummy_property_path), folder_cover_path)
    end

    def integrated_pdf_filename
      example_path('AssessmentPackage','merged')
    end

  end

end
