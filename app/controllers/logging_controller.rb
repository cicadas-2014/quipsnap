require 'nokogiri'

class LoggingController < ApplicationController
	
	# signing in with GoodReads 
	def sign_in
		host_and_port = request.host
		host_and_port << ":3000" if request.host == "localhost"
		
		request_token = oauth_consumer.get_request_token(:oauth_callback => "http://#{host_and_port}/auth")
		set_in_session(request_token)

		redirect_to request_token.authorize_url
	end

	# signing in with Twitter 
	def sign_in_twitter
		host_and_port = request.host
		host_and_port << ":3000" if request.host == "localhost"

		request_token = twitter_oauth_consumer.get_request_token(:oauth_callback => "http://#{host_and_port}/auth_twitter")
		set_in_session(request_token)

		redirect_to request_token.authorize_url
	end

	def sign_out
		session.clear
		redirect_to :home
	end

	# callback action after a user authorizes access to GoodReads 
	def auth
		request_token = create_request_token(oauth_consumer)

		begin
			@access_token = request_token.get_access_token
			response = @access_token.get('/api/auth_user')

			doc = Nokogiri::XML(response.body)
			goodreads_username, goodreads_user_id = parse_goodreads(doc)
			
			create_or_find_user(access_token: @access_token, username: goodreads_username, user_id: goodreads_user_id, is_twitter: false)
		rescue
			@not_authorized = true
			redirect_to :home
		end		
	end

	# callback action after a user authorizes access to Twitter
	def auth_twitter
		request_token = create_request_token(twitter_oauth_consumer)

		begin
			@access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
			twitter_handle = @access_token.params[:screen_name]
			user_id = @access_token.params[:user_id]

			create_or_find_user(access_token: @access_token, username: twitter_handle, user_id: user_id, is_twitter: true)
		rescue
			@not_authorized = true
			redirect_to :home
		end
	end

	private

	def create_request_token(consumer)
		token = OAuth::RequestToken.from_hash(
			consumer, 
			:oauth_token => session[:request_token], 
			:oauth_token_secret => session[:request_secret]
			)

		clear_request_token
		return token
	end

	def clear_request_token
		session.delete(:request_token)
		session.delete(:request_secret)
	end

	def create_or_find_user(user_info)
		@user = User.find_by(	goodreads_name: user_info[:username])
		
		if @user
			session[:user_id] = @user.id
			redirect_to :home
		else
			@user = User.create(goodreads_name: user_info[:username],
				goodreads_user_id: user_info[:user_id], 
				auth_token: user_info[:access_token].token, 
				auth_secret: user_info[:access_token].secret,
				is_twitter: user_info[:is_twitter])
			session[:user_id] = @user.id
			redirect_to :welcome
		end
	end

	def set_in_session(request_token)
		session[:request_token] = request_token.token
		session[:request_secret] = request_token.secret
	end

	def parse_goodreads(doc)
		user_xml = doc.at_xpath('//user')
		goodreads_user_id = user_xml.attributes["id"].value
		
		name_xml = doc.at_xpath('//name')
		goodreads_username = name_xml.children[0].inner_text

		return goodreads_username, goodreads_user_id
	end

end