require 'open-uri'
require 'nokogiri'
require 'goodreads'
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



  


end
