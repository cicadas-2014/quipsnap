class UsersController < ApplicationController

  # ROOT
  def index
  	@search = logged_in? ? Quote.where(user_id: current_user.id).search(params[:q]) : Quote.search(params[:q])
  	@quotes = @search.result.includes(:user).order("created_at DESC").paginate(page: params[:page], per_page: 5)
  	respond_to do |format|
  		format.html
  		format.js
  	end
  	@bookclubs = logged_in? ? current_user.bookclubs : nil
  end
end
