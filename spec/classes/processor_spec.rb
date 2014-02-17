require 'spec_helper'

def check_repository_contents
  folder_path = TestSetup.dummy_property_path
  expect(docupository.folder_exists?(folder_path)).to be true
  docupository.folder(folder_path)
  TestSetup.example_doc_names.each do |name|
    expect(docupository.file_exists?(name))
  end
end

describe "basic avlats operation", slow: true do

  let(:docupository) { @docupository }

  before(:all) do
    @docupository = DocFiler.new(ENV['COA_SCANS_NAME'], ENV['COA_SCANS_PASSWORD'], root: TestSetup.root_folder)
    @docupository.delete_folder_contents
    @docupository.add_folder_path(TestSetup.dummy_property_path)
    @docupository.folder('/')
  end

  describe "pdf_processor" do
    let(:integrated_file) { TestSetup.integrated_pdf_filename }
    it "should store files on Google drive" do
      docupository.interpret_pdf(integrated_file)
      check_repository_contents
    end
  end

end