class User < ActiveRecord::Base
  validates :goodreads_name, presence: true, uniqueness: true
  validates :auth_token, presence: true
  validates :auth_secret, presence: true

  has_many :quotes
  has_many :comments
  has_many :memberships
  has_many :bookclubs, through: :memberships
  has_many :owned_clubs, class_name: "Bookclub"
  has_many :quote_favorites
  has_many :favorites, through: :quote_favorites, source: :quote

	# Only allow users to use Ransack to search quotes by user's username
	def self.ransackable_attributes(auth_obj = nil)
		["goodreads_name"]
	end

end
