# http://www.pivotaltracker.com/story/show/928049
Feature: User withdraws money
  In order to be able to use funds deposited in the exchange
  As a user
  I wish to withdraw funds from exchange escrow


  Scenario: User clicks on withdraw funds
    Given the following users:
    | login    | balance |
    | roquezir | 420_000 |
    And roquezir is logged in
    And I am on the portfolio page
    When I fill in "withdrawal[amount]" with "29000"
    And I press "Send request"
    Then I should see "Request submitted to teller"

