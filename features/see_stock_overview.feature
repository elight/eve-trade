# http://www.pivotaltracker.com/story/show/928865
Feature: See stock overview
  In order to efficiently obtain information about a single stock
  As a stock purveyor
  I want to be able to see an overview of the history of the stock

  Scenario: See stock overview
    Given that I am logged in
    And the following stocks:
      |name|symbol|last_traded_value|last_traded_at|total_shares|
      |One Stop Research|OSR|30_000_000|#{Time.now - 30.minutes}|37_000|
    And the following transactions:
      |symbol|number_of_shares|sold_for|sold_at|
      |OSR|1_000|#{Time.now - 30.minutes}|29_500_000|
      |OSR|1_500|#{Time.now - 42.minutes}|28_000_000|
      |OSR|2_500|#{Time.now - 1.day}|27_000_000|
    When I go to the OSR stock page
    Then I should see "One Stop Research"
    And I should see "OSR"
    And I should see "37,000"
    And I should see "29,500,000 ISK / share"
    And I should see "Today's trading volume"
    And I should see "2,500"
