class OrJoinedSubscriberList < ApplicationRecord
  has_many :or_joined_subscriber_list_subscriber_lists
  has_many :subscriber_lists, through: :or_joined_subscriber_list_subscriber_lists
  #   Probably ought to do a dependent delete for the through table here
  has_many :subscriptions
  has_many :subscribers, through: :subscriptions
  has_many :matched_content_changes

  # TODO: As we are using this instead of the id, we want to add in a validation that this is
  # unique both for OrJoinedSubscriberLists and for SubscriberLists
  # We want to add the same validation in SubscriberLists too
  # At the time of writing (15th May at exactly 15:00) all 13,299
  # subscriber lists have unique slugs so it shouldn't be a breaking change
  validates :slug, presence: true

  def to_json
    #   I shan't bother coding this as it _shouldn't_ present any problems
    # Essentially it needs to return json with the same
    # attributes as a SubscriberList.to_json (but with it's own data)
  end

  def self.slug(subscriber_lists)
    # TODO: Test that this always returns the same slug no matter what order etc. the subscriber lists are in
    subscriber_lists.pluck(:slug).sort.join("-or-")
  end
end
