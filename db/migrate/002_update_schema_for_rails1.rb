class UpdateSchemaForRails1 < ActiveRecord::Migration
  def self.up
    rename_column :tasklists, :public, :is_public
    rename_column :tasklists, :shared, :is_shared
    rename_column :tasklists, :notify, :do_notification
  end

  def self.down
    rename_column :tasklists, :is_public, :public
    rename_column :tasklists, :is_shared, :shared
    rename_column :tasklists, :do_notification, :notify
  end
end
