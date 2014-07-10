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

  def parse_page_for_content_something(link)
    @page = Nokogiri::HTML(open(link))
    @links = @page.css('.quoteText a')
    @author_book_array = []
    @links.each do |link|
      @author_book_array << link.inner_text
    end
    @author_book_array
  end

  def parse_author
    @author_book_array[0]
  end

  def parse_book
    @author_book_array[1]
  end

  def parse_image
    @image_url = nil
    @image = @page.at_css(".quoteDetails.fullLine img")
    @image_url = @image.attributes["src"].value if @image
  end

  def parse_content(quote)
    quote.body.gsub("<br>","") #prevent line break <br> injections
  end

  def create_book
    @book = nil
    @book = Book.find_or_create_by(title: parse_book, image_url: parse_image) if parse_author
  end

  def create_author
    @author = Author.find_or_create_by(name: parse_author)
  end

  def create_quote(quote)
    @quote = Quote.create(content: parse_content(quote), goodreads_link: quote.link, author: @author, book: @book)
  end

  def create_new_quote(quote)
    parse_page_for_content_something(quote.link)
    parse_book
    parse_image  
    parse_author
    parse_content(quote)
    create_book
    create_author
    create_quote(quote)
  end

end
