Given(/^there are no topics$/) do
  # TODO: This may need to be more than a noop at some point
end

Then(/^a topic is created$/) do
  expect(GOV_DELIVERY_API_CLIENT.created_topics.values).to include(
    name: "CMA cases of type Markets and Mergers and about Energy",
  )

  # %{
  #   <topic>
  #     <name>CMA cases of type Markets and Mergers and about Energy</name>
  #     <visibility>Unlisted</visibility>
  #     <pagewatch-enabled type="boolean">false</pagewatch-enabled>
  #     <rss-feed-url nil="true"></rss-feed-url>
  #     <rss-feed-title nil="true"></rss-feed-title>
  #     <rss-feed-description nil="true"></rss-feed-description>
  #   </topic>
  # }
end
