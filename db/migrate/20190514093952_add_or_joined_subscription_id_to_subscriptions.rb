class AddOrJoinedSubscriptionIdToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :or_joined_subscriber_list_id, :integer
  end
end
