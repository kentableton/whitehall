class RemoveDeletedFromAttachments < ActiveRecord::Migration
  def change
    remove_column :attachments, :deleted, :boolean, null: false, default: false
  end
end
