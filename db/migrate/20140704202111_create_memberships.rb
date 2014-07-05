class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to    :bookclub
      t.belongs_to    :user

      t.timestamps
    end
  end
end
