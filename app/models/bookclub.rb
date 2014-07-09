class Bookclub < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates_length_of :name, maximum: 60

  has_many  :bookclub_quotes
  has_many  :quotes, through: :bookclub_quotes
  has_many  :memberships
  has_many  :users, through: :memberships

  belongs_to  :admin, class_name: "User", foreign_key: :user_id

  def as_json(options={})
    {
      id: id,
      name: name,
      admin_id: user_id,
      description: description,
      user_ids: users.pluck(:id)
    }
  end
end
