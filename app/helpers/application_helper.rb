require 'open-uri'
require 'nokogiri'
require 'goodreads'
require 'twitter'
module ApplicationHelper
  # need to fill this in. represents a logged in user, so we can make API calls on their behalf
  def goodreads_client
    @client ||= Goodreads::Client.new(:api_key => ENV['GR_KEY'], :api_secret => ENV['GR_SECRET'])
  end

  def get_quotes(user)
    updates = goodreads_client.user(user.goodreads_user_id).updates
    if updates
      user_recent_quotes = updates.select{|quote| quote.action_text == "liked a quote"}
      all_quote_content = Quote.pluck(:goodreads_link)
      user_recent_quotes.each do |quote|
        unless all_quote_content.include? quote.content
          recent_quote = create_new_quote(quote)
          user.quotes << recent_quote
        end
      end
    end
  end

  def create_new_quote(quote)
    page = Nokogiri::HTML(open(quote.link))
    links = page.css('.quoteText a')
    author_book_array = []
    links.each do |link|
      author_book_array << link.inner_text
    end
    image = page.at_css(".quoteDetails.fullLine img")
    
    if image
      @image_url = image.attributes["src"].value
    else
      @image_url = nil
    end
    
    if author_book_array[1]
      @book = Book.find_or_create_by(title: author_book_array[1], image_url: @image_url) 
    else
      @book = nil
    end
    
    @author = Author.find_or_create_by(name: author_book_array[0])
    
    Quote.create( content: quote.body, 
                  goodreads_link: quote.link, 
                  author: @author, book: @book)
  end

  def current_page?() 

  end

  # def twitter_client
  #     @twitter_client = Twitter::REST::Client.new do |config|
  #       config.consumer_key = ENV['TWITTER_KEY']
  #       config.consumer_secret = ENV['TWITTER_SECRET']
  #     end
  # end

  # def create_quotes_from_twitter(twitter_handle)
  #   tweet_links = []
  #   @twitter_client.user_timeline(twitter_handle).each do |tweet|
  #     if tweet.source.include?("kindle.amazon.com")
  #       p tweet_links << tweet.text.scan(/(http:\/\/t.co\/)([a-zA-Z]{10})/).first.join("")
  #     end
  #   end

  #   tweet_links.each do |link|
  #     page = Nokogiri::HTML(open(link))
  #     content = page.css('h1.quoteText').children.text
  #       if content.include?("â\u0080\u009C") || content.include?("â\u0080\u009D")
  #         content.strip!.gsub!("â\u0080\u009C","'").gsub!("â\u0080\u009D","'")
  #       end
  #     content.gsub!("â","'") if content.include?("â")
  #     author = page.css('div.quoteText a').children.first.text
  #     p book = page.css('div.quoteText i a').children.text

  #     @author = Author.find_or_create_by(name: author)
  #     @book = Book.find_or_create_by(title: book)
    
  #     Quote.create( content: content,
  #                   author: @author,
  #                   goodreads_link: link,
  #                   user_id: 3,
  #                   book: @book)

  #   end
  # end


end
