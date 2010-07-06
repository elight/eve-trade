# http://www.pivotaltracker.com/story/show/908432
Feature: Acquire funds from EVE user
  In order to provision a customer's account with funds
  As the EVETrade background process
  I want to be able to poll EVE for when customers send me money
  
  Scenario: poll EVE for updates
    Given the following users:
      |login|eve_character_id|eve_character_name|balance   |
      |roq  |42              |Roquezir          |0         |
      |low  |1764            |LadyOfWrath       |42_000_000|
    When I poll EVE for my deposits
    And I get the following deposits:
      |amount    |ownerID1|ownerName1|date               |
      |40_000_000|42      |Roquezir  |2009-07-17 06:02:00|
    Then I should have the following users:
      |login|balance   |
      |roq  |40_000_000|
      |low  |42_000_000|

  Scenario: receive deposit from person without account
    Given the following users:
      |login|eve_character_id|eve_character_name|balance   |
      |roq  |42              |Roquezir          |0         |
    When I poll EVE for my deposits
    And I get the following deposits:
      |amount  |ownerID1|ownerName1|date               |
      |40000000|42      |Roquezir  |2009-07-17 06:02:00|
    Then create a task to "Send Roquezir 40000000 ISK; Remind Roquezir to register on the EVE-Trade website first"
