class CreateOrJoinedSubscriberList < ActiveRecord::Migration[5.2]
  def change
    create_table :or_joined_subscriber_lists do |t|

      t.timestamps
    end
  end
end

