require 'spec_helper'

def check_repository_contents
  folder_path = TestSetup.dummy_property_path
  expect(docupository.folder_exists?(folder_path)).to be true
  docupository.change_working_directory(folder_path)
  TestSetup.example_doc_names.each do |name|
    expect(docupository.file_exists?(name))
  end
end

describe "basic avlats operation" do
  let(:docupository) { DocFiler.new(ENV['COA_SCANS_NAME'], ENV['COA_SCANS_PASSWORD']) }

  describe "pdf_processor" do
    let(:integrated_file) { TestSetup.integrated_pdf_filename }
    it "should store files on Google drive" do
      docupository.interpret_pdf(integrated_file)
      check_repository_contents
    end
  end

end