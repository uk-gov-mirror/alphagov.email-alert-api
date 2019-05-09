class MatchedContentChange < ApplicationRecord
  belongs_to :content_change
  belongs_to :subscriber_list
  has_many :matched_content_changes
end
