class AddIndices < ActiveRecord::Migration
  def change
  	add_index :quotes, :user_id
  	add_index :quotes, :author_id
  	add_index :quotes, :book_id
  	add_index :bookclub_quotes, :bookclub_id
  	add_index :bookclub_quotes, :quote_id
  	add_index :quote_favorites, :user_id
  	add_index :quote_favorites, :quote_id
  	add_index :comments, :parent_id
  	add_index :memberships, :bookclub_id
  	add_index :memberships, :user_id
  end
end
