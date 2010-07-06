# http://www.pivotaltracker.com/story/show/928864
Feature: Review my portfolio
  In order to know when to buy and sell certain stocks
  As a stock purveyor
  I want to see the state of stocks that I own shares in

  Scenario: See state of my stocks
    Given that I am logged in
    And the following stocks:
      |name|symbol|last_traded_value|last_traded_at|
      |One Stop Research|OSR|30_000_000|#{Time.now - 30.minutes}|
      |Dark Fusion Fleet|DFFT|1_000|#{Time.now - 42.minutes}|
    And the following portfolio:
      |name|symbol|number_of_shares|last_bought_at|
      |One Stop Research|OSR|5|22_000_000|
      |Dark Fusion Fleet|DFFT|100|900|
    When I go to the EVE-Trade home page
    Then I should see "One Stop Research"
    And I should see "5 shares"
    And I should see "22,000,000 ISK / share"
    And I should see "30,000,000 ISK / share"
    Then I should see "Dark Fusion Fleet"
    And I should see "100 shares"
    And I should see "900 ISK / share"
    And I should see "1,000 ISK / share"

  Scenario: See state of my stocks but I do not own any
    Given that I am logged in
    When I go to the EVE-Trade home page
    Then I should see "Portfolio is empty"
