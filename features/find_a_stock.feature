# http://www.pivotaltracker.com/story/show/928861
Feature: Find stocks
  In order to quickly obtain information about a stock
  As a stock purveyor
  I want to be able to easily find a stock in the exchange

  Scenario: Search for stock by name
    Given the following stocks:
      |symbol|ceo_id|name                |
      |OSMS  |42    |One Stop Mining Shop|
      |DFFT  |43    |Dark Fusion Fleet   |
      |OAO   |44    |One And Only        |
    And an ordinary user logged in as 'roquezir'
    And I am on the portfolio page
    When I fill in "search" with "One"
    And I press "Search"
    Then I should see "One Stop Mining Shop"
    And I should see "One and Only"

  Scenario: Search for stock by symbol
    Given the following stocks:
      |symbol|ceo_id|name                |
      |OSMS  |42    |One Stop Mining Shop|
      |DFFT  |43    |Dark Fusion Fleet   |
      |OAO   |44    |One And Only        |
    And an ordinary user logged in as 'roquezir'
    And I am on the portfolio page
    When I fill in "search" with "OSMS"
    And I press "Search"
    Then I should see "One Stop Mining Shop"

  Scenario: Search for stock by CEO
    Given the following users:
      |id|eve_character_name|
      |42|LadyOfWrath       |
    And the following stocks:
      |symbol|ceo_id|name                |
      |OSMS  |42    |One Stop Mining Shop|
      |DFFT  |43    |Dark Fusion Fleet   |
      |OAO   |44    |One And Only        |
    And an ordinary user logged in as 'roquezir'
    And I am on the portfolio page
    When I fill in "search" with "LadyOfWrath"
    And I press "Search"
    Then I should see "One Stop Mining Shop"
