# http://www.pivotaltracker.com/story/show/928862
Feature: See the latest news
  In order to know when to buy and sell certain stocks
  As a stock purveyor
  I want to see the latest news posted on the market

  Scenario: See the latest news
    Given that I am logged in
    And the following news items
      |name |body       |posted_at|
      |Lorem|Ipsum dolor|#{Time.now - 1.day}|
    When I go to the EVE-Trade home page
    Then I should see "Lorem"
    And I should see "Ipsum dolor"
