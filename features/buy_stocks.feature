# http://www.pivotaltracker.com/story/show/908367
Feature: Buy stocks
  In order to acquire partial ownership of a corporation
  As a stock purveyor
  I want to be able to buy stocks
  
  Scenario: Create a buy order
    Given that I am logged in
    And the following stocks:
      |name|symbol|last_traded_value|last_traded_at|
      |One Stop Research|OSR|30_000_000|#{Time.now - 30.minutes}|
    And I have "29800000" ISK
    And I am on "One Stop Research"
    When I fill in "Number of Shares" with "10"
    And I fill in "Offer Price" with "29800000"
    And I press "Submit buy order"
    Then I should see "Order placed!"
    And I should see "OSR @ 29800000 / share"
    And I should see "10 shares"

  Scenario: Attempt to create a buy order with inadequate funds
    Given that I am logged in
    And the following stocks:
      |name|symbol|last_traded_value|last_traded_at|asking_price|asking_units|
      |One Stop Research|OSR|30_000_000|#{Time.now - 30.minutes}|30_100_000|5|
    And I have "29500000" ISK
    And I am on "One Stop Research"
    When I fill in "Number of Shares" with "10"
    And I fill in "Offer Price" with "29800000"
    And I press "Submit buy order"
    Then I should see "We are sorry but your EVE-Trade account lacks the necessary funds"
    And I should see "OSR @ 29800000 / share"
    And I should see "10 shares"
    And I should see "298,000,000 ISK"
    And I should see "295,000,000 ISK"
    And I should see "Send 3,000,000 more ISK to"

  Scenario: Create a buy order matching a single sell order
    Given that I am logged in
    And the following stocks:
      |name|symbol|last_traded_value|last_traded_at|asking_price|asking_units|
      |One Stop Research|OSR|30_000_000|#{Time.now - 30.minutes}|30_100_000|5|
    And the following sell orders:
      |symbol|asking    |number_of_shares|
      |OSR   |34_000_000|5_000|
      |OSR   |32_000_000|100|
    And I have "100000000000" ISK
    And I am on "One Stop Research"
    When I fill in "Number of Shares" with "10"
    And I fill in "Offer Price" with "33500000"
    And I press "Submit buy order"
    And I should see "10 shares OSR bought @ 32,000,000 ISK"

  Scenario: Create a buy order requiring multiple sell orders
    Given that I am logged in
    And the following stocks:
      |name|symbol|last_traded_value|last_traded_at|asking_price|asking_units|
      |One Stop Research|OSR|30_000_000|#{Time.now - 30.minutes}|30_100_000|5|
    And the following sell orders:
      |symbol|asking    |number_of_shares|
      |OSR   |34_000_000|5_000|
      |OSR   |32_000_000|100|
    And I have "100000000000" ISK
    And I am on "One Stop Research"
    When I fill in "Number of Shares" with "200"
    And I fill in "Offer Price" with "35500000"
    And I press "Submit buy order"
    And I should see "100 shares OSR bought @ 32,000,000 ISK"
    And I should see "100 shares OSR bought @ 34,000,000 ISK"
