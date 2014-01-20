Feature: Testing basic avlats functionality
  Scenario: Site is up
    Given I am checking the website
  Scenario: Create a folder
    Given the dummy property folder is gone
    When I process an integrated PDF for the dummy property
    Then the property folder, assessment folder and asssessment letter are stored in Google drive
