require 'google_drive'
require_relative '../../app/modules/google_drive/path_methods'

def root_dir ; '/SewerLaterals/Properties/' ; end
def dummy_folder ; root_dir+'12345 Crescent' ; end

Given(/^I am checking the website$/) do
  site = "http://localhost:3000/"
  visit site
  page.should have_content('Process mail')
end

Given(/^the dummy property folder is gone$/) do
  session = GoogleDrive.login('coa.scans@gmail.com','cleanpipes')
  collection = session.collection_by_path(dummy_folder)
  collection.delete if collection
end

When(/^I mail a coversheet and report for the dummy property$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the property folder, assessment folder and the report are stored in Google drive$/) do
  pending # express the regexp above with the code you wish you had
end

