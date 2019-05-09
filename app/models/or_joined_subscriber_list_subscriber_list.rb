class OrJoinedSubscriberListSubscriberList < ApplicationRecord
  belongs_to :subscriber_list
  belongs_to :or_joined_subscriber_list
  #   Probably ought to do a dependent delete for the through table here
end
