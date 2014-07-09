class QuotesController < ApplicationController

  # GET /quotes/:id
  def show
  	@search = Quote.search(params[:q])
    @quote = Quote.find_by(id: params[:id])
  	render "show", locals: {quote: @quote} 
  end

  def search_by_category
    p params
    @search = Quote.search(params[:search_category] => params[:q][:book_title_cont])
    @search_term = convert_category_search

    @quotes = @search.result.includes(:user).order("created_at DESC").paginate(page: params[:page], per_page: 5)
    @bookclubs = logged_in? ? current_user.bookclubs : nil
    render "users/index"
  end

  def search
    @search = Quote.search(params[:q])
    @search_term = convert_search

  	@quotes = @search.result.includes(:user).order("created_at DESC").paginate(page: params[:page], per_page: 5)
  	@bookclubs = logged_in? ? current_user.bookclubs : nil
  	render "users/index"
  end
  
  # POST /quotes/:id/favorite
  def favorite
    @quote_fav = QuoteFavorite.new(user_id: current_user.id, quote_id: params[:id])
    @is_success = @quote_fav.save ? true : false
    render json: {isSuccess: @is_success}
  end

  # DELETE /quotes/:id/unfavorite
  def unfavorite
    @quote_fav = QuoteFavorite.find_by(user_id: current_user.id, quote_id: params[:id])
    @is_success = @quote_fav.destroy ? true : false
    render json: {isSuccess: @is_success}
  end

  # GET /favorites
  # returns json of current user's favorited quotes
  def favorites
    redirect_to home_path and return unless logged_in?
    @search = Quote.search(params[:q])
    @quotes = current_user.favorites.order("updated_at DESC")
    @bookclubs = logged_in? ? current_user.bookclubs : nil
    @favorite = true
    if request.xhr?
      render json: {quotes: @quotes}
    else
      @quotes = @quotes.paginate(page: params[:page], per_page: 5)
      render "users/index"
    end
  end

  private

  def convert_search

    conversion = {
      "book_title_cont" => "book titles",
      "author_name_cont" => "authors",
      "user_goodreads_name_cont" => "users"
    }

    if params[:q]
      return "Results for: #{conversion[params[:q].keys[0]]} '#{params[:q].values[0]}'"
    else
      return "Public Quotes"
    end

  end

  def convert_category_search
    
    conversion = {
      "book_title_cont" => "book titles",
      "author_name_cont" => "authors",
      "user_goodreads_name_cont" => "users"
    }

    if params[:q][:book_title_cont] != ""
      return "Results for: #{conversion[params[:search_category]]} '#{params[:q][:book_title_cont]}'"
    else
      return "Public Quotes"
    end

  end

end
