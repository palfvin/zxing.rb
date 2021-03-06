require 'spec_helper'
require 'zxing'

class Foo
  def path
    File.expand_path("../fixtures/example.png", __FILE__)
  end
end

describe ZXing do
  describe ".decode" do
    subject { ZXing.decode(file) }

    context "with a string path to image" do
      let(:file) { fixture_image("example") }
      it { should == "example" }
    end

    context "with a uri" do
      let(:file) { "http://2d-code.co.uk/images/bbc-logo-in-qr-code.gif" }
      it { should == "http://bbc.co.uk/programmes" }
    end

    context "with an instance of File" do
      let(:file) { File.new(fixture_image("example")) }
      it { should == "example" }
    end

    context "with an object that responds to #path" do
      let(:file) { Foo.new }
      it { should == "example" }
    end

    context "when the image cannot be decoded" do
      let(:file) { fixture_image("cat") }
      it { should be_nil }
    end

    context "when file does not exist" do
      let(:file) { 'nonexistentfile.png' }
      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError, "File nonexistentfile.png could not be found")
      end
    end

  end

  describe ".decode!" do
    subject { ZXing.decode!(file) }

    context "with a qrcode file" do
      let(:file) { fixture_image("example") }
      it { should == "example" }
    end

    context "when the image cannot be decoded" do
      let(:file) { fixture_image("cat") }
      it "raises an error" do
        expect { subject }.to raise_error(ZXing::UndecodableError, "Image not decodable")
      end
    end

    context "when the image cannot be decoded from a URL" do
      let(:file) { "http://www.google.com/logos/grandparentsday10.gif" }
      it "raises an error" do
        expect { subject }.to raise_error(ZXing::UndecodableError, "Image not decodable")
      end
    end

    context "when file does not exist" do
      let(:file) { 'nonexistentfile.png' }
      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError, "File nonexistentfile.png could not be found")
      end
    end
  end

  describe ".decode_all" do
    subject { ZXing.decode_all(file) }

    context "with a single barcoded image" do
      let(:file) { fixture_image("example") }
      it { should == ["example"] }
    end

    context "with a multiple barcoded image" do
      let(:file) {fixture_image("multi_barcode_example") }
      it { should == ['test456','test123']}
    end

    context "when the image cannot be decoded" do
      let(:file) { fixture_image("cat") }
      it { should == [] }
    end

    context "when file does not exist" do
      let(:file) { 'nonexistentfile.png' }
      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError, "File nonexistentfile.png could not be found")
      end
    end

  end

  describe ".decode_all!" do
    subject { ZXing.decode_all!(file) }

    context "with a single barcoded image" do
      let(:file) { fixture_image("example") }
      it { should == ["example"] }
    end

    context "with a multiple barcoded image" do
      let(:file) {fixture_image("multi_barcode_example") }
      it { should == ['test456','test123']}
    end

    context "when the image cannot be decoded" do
      let(:file) { fixture_image("cat") }
      it "raises an error" do
        expect { subject }.to raise_error(ZXing::UndecodableError, "Image not decodable")
      end
    end

    context "when file does not exist" do
      let(:file) { 'nonexistentfile.png' }
      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError, "File nonexistentfile.png could not be found")
      end
    end
  end

  describe ".decode with options" do
    subject { ZXing.decode(file, options) }
    let(:file) { fixture_image("example")}

    context "that select a valid cropping of a single code" do
      let(:options) { {crop: {x: 0.1, y: 0.1, width: 0.8, height: 0.8}} }
      it { should == "example" }
    end

    context "that select an invalid cropping of a single code" do
      let(:options) { {crop: {x: 0.5, y: 0.5, width: 0.3, height: 0.4}} }
      it { should be_nil }
    end

    context "that request retry with rotation on image with data that looks like finder code" do
      let(:options) { {rotate_and_retry_on_failure: true} }
      let(:file) { fixture_image("62_canyon") }
      it { should == "COVER:\n62 CANYON TERRACE RD" }
    end

  end

end
