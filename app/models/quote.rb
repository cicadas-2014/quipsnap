class Quote < ActiveRecord::Base
	validates :content, presence: true
	validates :goodreads_link, presence: true, uniqueness: true

	belongs_to :user
	belongs_to :author
	belongs_to :book

	has_many :comments
	has_many	:bookclub_quotes
	has_many	:bookclubs, through: :bookclub_quotes
	has_many :quote_favorites
	has_many :favorited_users, through: :quote_favorites, source: :user

	# Returns an array of nested hashes, where each element in the array represents a direct comment and its chain of replies
	def comment_chain
		comments.map { |comment| comment.all_replies }
	end

	# Only allow users to use Ransack to search quotes by title and author
	# Overwrite Ransack built-in method
	def self.ransackable_attributes(auth_obj = nil)
		[]
	end
	
	# Only allow users to use Ransack to search quotes by user
	def self.ransackable_associations(auth_obj = nil)
		["user", "author", "book"]
	end

	def as_json(options={})
		{
			id: id,
			content: content,
			user_id: user_id,
			created_at: created_at,
			updated_at: updated_at,
			book_id: book_id,
			author_id: author_id,
			author_name: author.name,
			user_name: user.goodreads_name,
			book_title: book.nil? ? "" : book.title
		}
	end
end