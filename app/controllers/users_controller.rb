class UsersController < ApplicationController

  include ApplicationHelper

  # ROOT
  def index
  	@search = logged_in? ? Quote.where(user_id: current_user.id).search(params[:q]) : Quote.search(params[:q])
  	@quotes = @search.result.includes(:user).order("created_at DESC")
  	@bookclubs = logged_in? ? current_user.bookclubs : nil
    if @quotes
      @quotes=@quotes.paginate(page: params[:page], per_page: 5)
    end

    # respond_to do |format|
    #   format.html { 
    #     if logged_in?
    #       render :index
    #     end
    #   }
    #   format.js {
    #     if !logged_in?
    #       render js: :index
    #     end
    #   }
    # end


    respond_to do |format| 
      format.html {render :index if logged_in?}
      format.js
    end
  end

  def welcome
    @search = logged_in? ? Quote.where(user_id: current_user.id).search(params[:q]) : Quote.search(params[:q])
    @quotes = @search.result.includes(:user).order("created_at DESC")
  end

  def retrieve_quotes
    if current_user.is_twitter 
      create_quotes_from_twitter(current_user)
    else
      get_quotes(current_user)
    end
  end

end
