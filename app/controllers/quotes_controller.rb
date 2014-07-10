class QuotesController < ApplicationController

  CONVERSION = {
    "book_title_cont" => "book titles",
    "author_name_cont" => "authors",
    "user_goodreads_name_cont" => "users"
  }

  def show
    @search = Quote.search(params[:q])
    @quote = Quote.find_by(id: params[:id])
    render "show", locals: {quote: @quote} 
  end

  def search_by_category
    @search = Quote.search(params[:search_category] => params[:q][:book_title_cont])
    @search_term = convert_category_search

    @quotes, @bookclubs = get_quotes_and_bookclubs(@search)
    
    render "users/index"
  end

  def search
    @search = Quote.search(params[:q])
    @search_term = convert_search

    @quotes, @bookclubs = get_quotes_and_bookclubs(@search)

    render "users/index"
  end

  def favorite
    @quote_fav = QuoteFavorite.new(user_id: current_user.id, quote_id: params[:id])
    @is_success = @quote_fav.save ? true : false
    render json: {isSuccess: @is_success}
  end

  def unfavorite
    @quote_fav = QuoteFavorite.find_by(user_id: current_user.id, quote_id: params[:id])
    @is_success = @quote_fav.destroy ? true : false
    render json: {isSuccess: @is_success}
  end

  # returns json of current user's favorited quotes
  def favorites
    redirect_to home_path and return unless logged_in?

    @search = Quote.search(params[:q])
    @quotes, @bookclubs = get_favorites_and_bookclubs
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
    if params[:q]
      return "Results for: #{CONVERSION[params[:q].keys[0]]} '#{params[:q].values[0]}'"
    else
      return "All Quotes"
    end
  end

  def convert_category_search
    if params[:q][:book_title_cont] != ""
      return "Results for: #{CONVERSION[params[:search_category]]} '#{params[:q][:book_title_cont]}'"
    else
      return "All Quotes"
    end
  end

  def get_quotes_and_bookclubs(search)
    quotes = search.result.includes(:user).order("created_at DESC").paginate(page: params[:page], per_page: 5)
    bookclubs = logged_in? ? current_user.bookclubs : nil    
    return quotes, bookclubs
  end

  def get_favorites_and_bookclubs
    quotes = current_user.favorites.order("updated_at DESC")
    bookclubs = logged_in? ? current_user.bookclubs : nil
    return quotes, bookclubs
  end

end
