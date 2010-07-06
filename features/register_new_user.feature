# http://www.pivotaltracker.com/story/show/908368
Feature: Registering new user
  In order to securely and uniquely identify my EVE character to EVE-Trade
  As an EVE player
  I want to supply my EVE credentials to EVE-Trade

  Scenario: New user with a single character
    Given an EVE user
    And an EVE character named "Foobar"
    And I am on the user registration page
    When I fill in "API Key" with "1F8700792C73426BB6404286CEC614A9E25889BF7576D0048AE0B61BCED1693F"
    And I fill in "User ID" with "5328245"
    And I press "Register"
    Then I should be on the main page
    And I should see "Foobar"
    And I should see "Account created successfully"

  Scenario: New user with multiple characters
    Given an EVE user
    And an EVE character named "Foobar"
    And an EVE character named "Blech"
    And I am on the user registration page
    When I fill in "API Key" with "1F8710792C73426BB6404286CEC617A9E25889BF7676D0048AE0B61BCED1693F"
    And I fill in "User ID" with "5328205"
    And I press "Register"
    Then I should be on the character selection page
    And I should see "Foobar"
    And I should see "Blech"

  Scenario: New user with multiple characters has provided credentials
    Given an EVE user
    And an EVE character named "Foobar"
    And an EVE character named "Blech"
    And I have provided my credentials
    And I am on the character selection page
    When I select "Foobar" from "Character"
    And I press "Register"
    Then I should be on the main page
    And I should see "Foobar"
    And I should see "Account created successfully"

  Scenario: New user with invalid credentials
    Given an EVE user
    And I am on the user registration page
    When I fill in "API Key" with "1F8700792C73426BB6404286CEC614A9E25889BF7576D0048AE0B61BCED1693F"
    And I fill in "User ID" with "5328245"
    And my credentials are invalid
    And I press "Register"
    Then I should be on the user registration page
    And I should see "Sorry but either your API Key or User ID appear to be invalid.  Please try again."
