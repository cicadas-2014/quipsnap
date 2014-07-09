require 'nokogiri'

class LoggingController < ApplicationController
	

	# GET /sign_in
	# 	signing in with OAuth
	def sign_in
		host_and_port = request.host
		host_and_port << ":3000" if request.host == "localhost"
		request_token = oauth_consumer.get_request_token(:oauth_callback => "http://#{host_and_port}/auth")
		session[:request_token] = request_token.token
		session[:request_secret] = request_token.secret
		redirect_to request_token.authorize_url
	end

	def sign_in_twitter
		host_and_port = request.host
		host_and_port << ":3000" if request.host == "localhost"
		request_token = twitter_oauth_consumer.get_request_token(:oauth_callback => "http://#{host_and_port}/auth_twitter")
		session[:request_token] = request_token.token
		session[:request_secret] = request_token.secret
		redirect_to request_token.authorize_url
	end 

	# GET /sign_out
	def sign_out
		session.clear
		redirect_to :home
	end

	# GET /auth
	# 	after a user authorizes access to GoodReads 
	def auth
		request_token = OAuth::RequestToken.from_hash(oauth_consumer, 
			:oauth_token => session[:request_token], 
			:oauth_token_secret => session[:request_secret])
		begin
			@access_token = request_token.get_access_token
			session.delete(:request_token)
			session.delete(:request_secret)
			response = @access_token.get('/api/auth_user')
			doc = Nokogiri::XML(response.body)
			user_xml = doc.at_xpath('//user')
			goodreads_user_id = user_xml.attributes["id"].value
			name_xml = doc.at_xpath('//name')
			goodreads_username = name_xml.children[0].inner_text
			@user = User.find_by(	goodreads_name: goodreads_username)
			if @user
				session[:user_id] = @user.id
				redirect_to :home
			else
				@user = User.create( goodreads_name: goodreads_username,
					goodreads_user_id: goodreads_user_id, 
					auth_token: @access_token.token, 
					auth_secret: @access_token.secret)
				session[:user_id] = @user.id
				redirect_to :welcome
			end
		rescue
			session.delete(:request_token)
			session.delete(:request_secret)
			@not_authorized = true
			redirect_to :home
		end		
	end

	def auth_twitter
		request_token = OAuth::RequestToken.from_hash(twitter_oauth_consumer, 
			:oauth_token => session[:request_token], 
			:oauth_token_secret => session[:request_secret])
		begin
			@access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
			session.delete(:request_token)
			session.delete(:request_secret)
			twitter_handle = @access_token.params[:screen_name]
			@user = User.find_by(	goodreads_name: twitter_handle)
			if @user
				session[:user_id] = @user.id
				redirect_to :welcome
			else
				@user = User.create( goodreads_name: twitter_handle,
					goodreads_user_id: @access_token.params[:user_id], 
					auth_token: @access_token.token, 
					auth_secret: @access_token.secret,
					is_twitter: true)
				session[:user_id] = @user.id
				redirect_to home_path
			end
		rescue
			session.delete(:request_token)
			session.delete(:request_secret)
			@not_authorized = true
			redirect_to :home
		end		
	end
end