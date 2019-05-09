class OrJoinedSubscriberList < ApplicationRecord
  has_many :or_joined_subscriber_list_subscriber_lists
  has_many :subscriber_lists, through: :or_joined_subscriber_list_subscriber_lists
  #   Probably ought to do a dependent delete for the through table here
  has_many :subscriptions
  has_many :subscribers, through: :subscriptions
  has_many :matched_content_changes


end
