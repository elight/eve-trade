# http://www.pivotaltracker.com/story/show/928863
Feature: See most recently listed stocks
  In order to know when to buy new stocks
  As a stock purveyor
  I want to see a list of the most recently listed stocks

  Scenario: See the most recently listed stocks
    Given that I am logged in
    And the following stocks:
      |name|symbol|created_at|
      |One Stop Research|OSR|#{Time.now - 30.minutes}|
      |Dark Fusion Fleet|DFFT|#{Time.now - 42.minutes}|
      |Pator Tech School|PTS|#{Time.now - 1.year}|
      |Something|SOM|#{Time.now - 4.years}|
      |Or|OR|#{Time.now - 3.years}|
      |Other|OT|#{Time.now - 3.months}|
    When I go to the EVE-Trade home page
    Then I should see "One Stop Research"
    And I should see "Dark Fusion Fleet"
    And I should see "Pator Tech School"
    And I should see "Or"
    And I should see "Other"
    And I should not see "Something"


