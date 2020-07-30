class DropFailureReasonFromEmails < ActiveRecord::Migration[6.0]
  def change
    remove_column :emails, :failure_reason
  end
end
