class AddOrJoinedSubscriberListIdToMatchedContentChange < ActiveRecord::Migration[5.2]
  def change
    add_column :matched_content_changes, :or_joined_subscriber_list_id, :bigint
    change_column_null :matched_content_changes, :subscriber_list_id, false
  end
end
