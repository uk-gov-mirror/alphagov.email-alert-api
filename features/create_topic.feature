Feature: Create a topic
  Create a topic from a title and a set of tags

  Scenario: Creating a new topic
    Given there are no topics
    When I POST to "/topics" with
      """
      {
        "title": "CMA cases of type Markets and Mergers and about Energy",
        "tags": {
          "document_type": [ "cma_case" ],
          "case_type": [ "markets", "mergers" ],
          "market_sector": [ "energy" ]
        }
      }
      """
    Then a topic is created
    And I get the response
      """
      {
        "subscription_url": "https://stage-public.govdelivery.com/accounts/UKGOVUK/subscriber/new?topic_id=ABC_1234"
      }
      """
