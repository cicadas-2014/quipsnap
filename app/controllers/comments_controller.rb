class CommentsController < ApplicationController
	
	# POST /quotes/:quote_id/comments/create
		# when the comment is a reply to a quote
		# params[:comment_id] will be nil (i.e. it is a root comment for a quote comment tree)
	# POST /quotes/comments/:comment_id/create 
		# when the comment is a reply to another comment
		# params[:comment_id] will be the id of that comment	
	def create
		@comment = Comment.new(
			content: params[:comment], 
			user_id: current_user.id, 
			parent_id: params[:comment_id].to_i,
			quote_id: params[:quote_id].to_i
			)

		@isSuccess = @comment.save ? true : false

		render json: { 
			isSuccess: @isSuccess, 
			comment_content: @comment.content, 
			comment_id: @comment.id, 
			user: @comment.user.goodreads_name,
			parent_id: params[:comment_id],
			quote_id: params[:quote_id] 
		}
	end

	# GET /comments/replies
	# receives an array of comment id's and returns the nested comment chain for each of those comments
	def get_replies
		reply_chain = params[:comment_ids].nil? ? [] : params[:comment_ids].map{ |id| Comment.find(id.to_i).all_replies }
		render json: { comments: reply_chain, isLoggedIn: logged_in? }
	end

end
