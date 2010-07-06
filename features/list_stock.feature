# http://www.pivotaltracker.com/story/show/908334
Feature: List my corporation
  In order to raise funds for my corporation
  As a Corporate CEO I want to be able to adjust my corporation's stock's information in EVE-Trade

  Scenario: Unlisted corporate CEO accesses corporation management page
    Given a CEO user logged in as 'researcher'
    And my corporation is One Stop Research (OSRS)
    And I am on the portfolio page
    When I follow "corporate management"
    Then I should see "corporate management"
    And I should see "list my corporation on EVE-trade"

  Scenario: Listed corporate CEO accesses corporation management page
    Given a CEO user logged in as 'researcher'
    And my corporation is One Stop Research (OSRS)
    And my corporation is listed
    And I am on the portfolio page
    When I follow "corporate management"
    Then I should see "corporate management"
    And I should see "post news about One Stop Research (OSRS)"
    And I should not see "list my corporation on EVE-trade"

  Scenario: Select list my corporation's stock
    Given a CEO user logged in as 'researcher'
    And my corporation is One Stop Research (OSRS)
    And I am on the corporate management page
    When I follow "list my corporation on EVE-trade"
    Then I should see "List One Stop Research (OSRS) on EVE-trade"
    And I should see "I wish to list shares that exist..."
    And I should see "... in EVE"
    And I should see "... only on this website"
