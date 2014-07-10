class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?, :oauth_consumer, :goodreads_client, :get_quotes, :twitter_oauth_consumer

  def current_user
    @user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !(current_user.nil?)
  end

  def oauth_consumer
    @consumer ||= OAuth::Consumer.new(
      ENV['GR_KEY'], 
      ENV['GR_SECRET'], 
      :site => 'http://www.goodreads.com')
  end

  def twitter_oauth_consumer
    @consumer ||= OAuth::Consumer.new(
      ENV['TWITTER_KEY'], 
      ENV['TWITTER_SECRET'], 
      :site => "https://api.twitter.com")
  end
end