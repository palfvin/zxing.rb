require 'spec_helper'
require_relative '../../app/modules/google_drive/path_methods'

describe 'GoogleDrive::Session#collection_by_pathname' do
  let(:session) { GoogleDrive.login('coa.scans@gmail.com','cleanpipes') }
  before do
    tmp = session.collection_by_title('tmp')
    tmp.delete if tmp
    root = session.root_collection
    tmp = root.create_subcollection('tmp')
    foo = tmp.create_subcollection('foo')
    foo.create_subcollection('bar')
  end

  it "should find collection by path" do
    foo = session.collection_by_path('tmp/foo')
    expect(foo.files.map(&:title)).to eql(['bar'])
  end
end



