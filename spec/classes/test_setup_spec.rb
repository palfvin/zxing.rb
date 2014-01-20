require 'spec_helper'

describe TestSetup do
  it "should make pdf" do
    TestSetup.make_integrated_pdf
    expect(File.exists?(TestSetup.integrated_pdf_filename)).to be true
  end
end
