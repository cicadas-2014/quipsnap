class AddTwitterColumnToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :is_twitter, :boolean
  end
end
