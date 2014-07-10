class BookclubsController < ApplicationController

  def index
    redirect_to home_path unless logged_in?
    @search = Quote.search(params[:q])
    @bookclub = Bookclub.new
  end

  def all
    if request.xhr?
      @bookclubs = Bookclub.order(user_id: :asc)
      render json: { bookclubs: @bookclubs }.to_json
    else
      redirect_to home_path
    end
  end

  def create
    @bookclub = Bookclub.new(bookclub_params)
    @bookclub.admin = current_user
    
    if @bookclub.save
      @bookclub.users << current_user
      render json: { bookclub: @bookclub }.to_json
    else
      render status: :unprocessable_entity, json: { message: "Can't add bookclub!" }.to_json
    end
  end

  def show
    redirect_to home_path and return unless logged_in?

    @search = Quote.search(params[:q])
    @bookclub = Bookclub.find_by(id: params[:bookclub_id])

    @bookclubs = current_user.bookclubs
    @quotes = @bookclub.quotes.order("updated_at DESC").paginate(page: params[:page], per_page: 5)


    if request.xhr?
      @favorites = @quotes.map do |quote| 
        QuoteFavorite.find_by(quote_id: quote.id, user_id: current_user.id) ? true : false
      end
      render json: {quotes: @quotes, is_favorites: @favorites, name: @bookclub.name, desc: @bookclub.description } 
    else
      render "users/index"
    end

  end

  def delete
    bookclub = Bookclub.find_by(id: params[:id])
    bookclub.destroy
    render json: {done: "Deleted bookclub!"}
  end

  def add_quote
    @quote = Quote.find_by(id: params[:quote_id])
    @bookclub = Bookclub.find_by(id: params[:bookclub_id])

    if @bookclub.quotes.include?(@quote)
      quote_added = false
    else
      quote_added = true
      @bookclub.quotes << @quote
    end

    render json: {quote_added: quote_added}
  end


  def join
    bookclub = Bookclub.find_by(id: params[:bookclub_id])
    bookclub.users << current_user
    render json: { bookclub_id: bookclub.id }.to_json
  end

  private

  def bookclub_params
    params.require(:bookclub).permit(:name, :description)
  end

end