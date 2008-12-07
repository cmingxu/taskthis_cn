class InitialSchema < ActiveRecord::Migration
  def self.up

   create_table :taskitems do |table|
      table.column :tasklist_id, :integer
      table.column :user_id, :integer
      table.column :title, :string
      table.column :notes, :text
      table.column :notes_html, :text
      table.column :complete, :integer, :default=>0
      table.column :position, :integer
      table.column :due_on, :datetime
      table.column :created_on, :datetime
      table.column :updated_on, :datetime
   end

   create_table :tasklists do |table|
      table.column :user_id, :integer
      table.column :name, :string, :limit=>100
      table.column :title, :string, :limit=>100
      table.column :description, :text
      table.column :description_html, :text
      table.column :public, :integer, :default=>0
      table.column :shared, :integer, :default=>0
      table.column :position, :integer
      table.column :notify, :integer, :default=>0
      table.column :view_in_sidebar, :integer, :default=>1
      table.column :created_on, :datetime
      table.column :updated_on, :datetime
   end

   # For future use...
   create_table :tasklists_users do |table|
      table.column :tasklist_id, :integer
      table.column :user_id, :integer
   end

   create_table :users do |table|
      table.column :name, :string, :limit=>100
      table.column :email, :string
      table.column :login, :string, :limit=>80
      table.column :password, :string, :limit=>40
      table.column :remembrall, :string, :limit=>40
      table.column :remembrall_expired, :datetime
      table.column :admin, :integer, :default=>0
      table.column :prefs, :text
      table.column :last_login, :datetime
      table.column :created_on, :datetime
      table.column :updated_on, :datetime
   end

  end

  def self.down
     drop_table :taskitems
     drop_table :tasklists
     drop_table :tasklists_users
     drop_table :users
  end
end
