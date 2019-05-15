class AddSlugToOrJoinedSubscriberList < ActiveRecord::Migration[5.2]
  def change
    add_column :or_joined_subscriber_lists, :slug, :string
  end
end
