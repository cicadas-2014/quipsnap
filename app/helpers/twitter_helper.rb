require 'twitter'
require 'open-uri'
require 'nokogiri'
require 'net/http'
require "uri"
require 'open_uri_redirections'
require 'htmlentities'
require 'httpclient'



module TwitterHelper


	def encoder
		@coder = HTMLEntities.new
	end

	def twitter_client
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_KEY']
        config.consumer_secret = ENV['TWITTER_SECRET']
      end
  end

  def create_quotes_from_twitter(user)
    tweet_goodreads_links = []
    tweet_amazon_links = []
    link_search = /(http:\/\/t.co\/)([a-zA-Z0-9]{10})/

    @twitter_client.user_timeline(user.goodreads_name).each do |tweet|
      if tweet.source.include?("kindle.amazon.com")
    		url = tweet.text.scan(link_search).first.join("")
    		link = ""
	    	open(url,:allow_redirections => :safe) do |resp|
	  			link << resp.base_uri.to_s
				end
      	if link.include?("goodreads")
      		tweet_goodreads_links << link
      	else
        	tweet_amazon_links << link
        end
      end
    end

    tweet_goodreads_links.each do |link|
    	@page = open(link, :allow_redirections => :safe)
      doc = Nokogiri::HTML.parse(@page)
      content = @coder.decode(doc.css('h1.quoteText').children.text)
    	author = doc.css('div.quoteText a').children.first.text.tr(%q{"'}, '')
      book = doc.css('div.quoteText i a').children.text


      @author = Author.find_or_create_by(name: author)
      @book = Book.find_or_create_by(title: book)
    
      if content.include?("â\u0080\u009C") || content.include?("â\u0080\u009D")
        content.strip!.gsub!("â\u0080\u009C","'").gsub!("â\u0080\u009D","'")
      end

      content.gsub!("â\u0080\u0099d", "'") if content.include?("â\u0080\u0099d")

      Quote.create( content: content,
                    author: @author,
                    goodreads_link: link,
                    user_id: user.id,
                    book: @book)


    end

    tweet_amazon_links.each do |link|
    	@page = open(link, :allow_redirections => :safe)
      doc = Nokogiri::HTML.parse(@page)
      content = @coder.decode(doc.css("script")[1].to_s.scan(/(?<=content":")(.*)(?=","customerId)/)[0][0])
    


      if content.include?("â\u0080\u009C") || content.include?("â\u0080\u009D")
        content.strip!.gsub!("â\u0080\u009C","'").gsub!("â\u0080\u009D","'")
      end

      content.gsub!("â\u0080\u0099d", "'") if content.include?("â\u0080\u0099d")

      book = doc.css("script")[1].to_s.scan(/(?<=title":")(.*)(?=","title)/)[0][0]
      author = doc.css("script")[1].to_s.scan(/(?<=authors":\[)(.*)(?=\],"content)/)[0][0].tr(%q{"'}, '')
      @author = Author.find_or_create_by(name: author)
      @book = Book.find_or_create_by(title: book)
    
      Quote.create( content: content,
                    author: @author,
                    goodreads_link: link,
                    user_id: user.id,
                    book: @book)

    end
  end  
end