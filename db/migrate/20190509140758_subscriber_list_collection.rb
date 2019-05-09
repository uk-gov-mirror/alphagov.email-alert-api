class SubscriberListCollection < ActiveRecord::Migration[5.2]
  def change
    create_table :or_joined_subscriber_list_subscriber_lists do |t|
      t.integer :subscriber_list_id
      t.integer :or_joined_subscriber_list_id
      t.timestamps null: false
    end
    add_index :or_joined_subscriber_list_subscriber_lists, [:id, :subscriber_list_id], name: "idx_or_joined_sub_list_sub_list_on_sub_list_id"
    add_index :or_joined_subscriber_list_subscriber_lists, [:id, :or_joined_subscriber_list_id], name: "idx_or_joined_sub_list_sub_list_on_or_joined_sub_list_id"
  end
end
