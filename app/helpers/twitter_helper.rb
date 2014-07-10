require 'twitter'
require 'open-uri'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'open_uri_redirections'
require 'htmlentities'
require 'httpclient'



module TwitterHelper


	def encoder
		@coder ||= HTMLEntities.new
	end

	def twitter_client
    @twitter_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_KEY']
      config.consumer_secret = ENV['TWITTER_SECRET']
    end
  end

  def twitter_link_search
    link_search = /(http:\/\/t.co\/)([a-zA-Z0-9]{10})/
  end

  def twitter_link(tweet)
    url = tweet.text.scan(twitter_link_search).first.join("")
  end

  def store_goodreads_urls(url)
    @goodreads_urls << url
  end

  def store_amazon_urls(url)
    @amazon_urls << url
  end

  def twitter_redirect_url(tweet)
    url = ""
    open(twitter_link(tweet),:allow_redirections => :safe) do |resp|
      url << resp.base_uri.to_s
    end
    return url
  end

  def grab_links_for_twitter_user
    @goodreads_urls = []
    @amazon_urls = []
    twitter_client.user_timeline(@user.goodreads_name).each do |tweet|
      if tweet.source.include?("kindle.amazon.com")
        if twitter_redirect_url(tweet).include?("goodreads")
          store_goodreads_urls(twitter_redirect_url(tweet))
        else
          store_amazon_urls(twitter_redirect_url(tweet))
        end
      end
    end
  end

  def create_quotes_from_twitter(user)
    @user = user
    grab_links_for_twitter_user
    create_goodreads_quotes
    create_amazon_quotes
  end

  def create_goodreads_quotes
    @goodreads_urls.each do |url|
      parse_page_for_content(url)
      parse_goodreads_content
      parse_goodreads_author
      parse_goodreads_book
      create_goodreads_quote(url)
    end
  end

  def create_amazon_quotes
    @amazon_urls.each do |url|
      parse_page_for_content(url)
      parse_amazon_content
      parse_amazon_author
      parse_amazon_book
      create_amazon_quote(url)
    end
  end

  def create_amazon_quote(url)
    author_name = parse_amazon_author 
    @author = Author.find_or_create_by(name: author_name)
    book_title = parse_amazon_book 
    @book = Book.find_or_create_by(title: book_title)

    Quote.create( content: @content,
                    author: @author,
                    goodreads_link: url,
                    user_id: @user.id,
                    book: @book)
  end

  def create_goodreads_quote(url)
    author_name = parse_goodreads_author 
    @author = Author.find_or_create_by(name: author_name)
    book_title = parse_goodreads_book 
    @book = Book.find_or_create_by(title: book_title)

    Quote.create( content: @content,
                    author: @author,
                    goodreads_link: url,
                    user_id: @user.id,
                    book: @book)
  end
  

  def parse_page_for_content(link)
    @page = open(link, :allow_redirections => :safe)
    @doc = Nokogiri::HTML.parse(@page)    
  end

  def parse_goodreads_content
    @content = encoder.decode(@doc.css('h1.quoteText').children.text)
    if @content.include?("â\u0080\u009C") || @content.include?("â\u0080\u009D")
      @content.strip!.gsub!("â\u0080\u009C","'").gsub!("â\u0080\u009D","'")
    end
    @content.gsub!("â\u0080\u0099", "'") if @content.include?("â\u0080\u0099")
  end

  def parse_amazon_content
    @content = encoder.decode(@doc.css("script")[1].to_s.scan(/(?<=content":")(.*)(?=","customerId)/)[0][0])
    if @content.include?("â\u0080\u009C") || @content.include?("â\u0080\u009D")
      @content.strip!.gsub!("â\u0080\u009C","'").gsub!("â\u0080\u009D","'")
    end
    @content.gsub!("â\u0080\u0099", "'") if @content.include?("â\u0080\u0099")
  end

  def parse_goodreads_author
    @doc.css('div.quoteText a').children.first.text.tr(%q{"'}, '')
  end

  def parse_goodreads_book
    @doc.css('div.quoteText i a').children.text
  end

  def parse_amazon_book
    @doc.css("script")[1].to_s.scan(/(?<=title":")(.*)(?=","title)/)[0][0]
  end

  def parse_amazon_author
    author = @doc.css("script")[1].to_s.scan(/(?<=authors":\[)(.*)(?=\],"content)/)[0][0].tr(%q{"'}, '')
  end

end