class Comment < ActiveRecord::Base
	validates :content, presence: true
	validates :user, presence: true

	belongs_to :user
	belongs_to :quote

	# recursively call to get the entire reply chain for a single comment
	def all_replies
		chain = { 
							comment_id: self.id, 
							parent_id: self.parent_id, 
							quote_id: self.quote_id, 
							comment_content: self.content, 
							user: self.user.goodreads_name, 
							replies: [] 
						}
		direct_replies.each { |reply| chain[:replies] << reply.all_replies }
		chain
	end
	
	# direct replies to a comment 
	def direct_replies
		Comment.where(parent_id: self.id)
	end

end
