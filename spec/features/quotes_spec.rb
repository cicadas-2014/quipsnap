require 'rails_helper'

feature 'Search Quotes', :js => true do

	let!(:quote) { create(:quote) }
	let!(:quote_2) { create(:quote) }

	scenario 'search by title' do
		visit home_path
		find("option[value='book_title_cont']").click
		fill_in "q_book_title_cont", with: quote.book.title
		find('.search').click
		expect(page).to have_content(quote.book.title)
		expect(page).to_not have_content(quote_2.book.title)
	end

	scenario 'search by author' do
		visit home_path
		find("option[value='author_name_cont']").click
		fill_in "q_book_title_cont", with: quote.author.name
		find('.search').click
		expect(page).to have_content(quote.author.name)
		expect(page).to_not have_content(quote_2.author.name)
	end

	scenario 'search by username' do
		visit home_path
		find("option[value='user_goodreads_name_cont']").click
		fill_in "q_book_title_cont", with: quote.user.goodreads_name
		find('.search').click
		expect(page).to have_content(quote.user.goodreads_name)
		expect(page).to_not have_content(quote_2.user.goodreads_name)
	end

end

feature 'Show Quote Page', :js => true do

	let!(:user) { create(:user) }
	let!(:quote) { create(:quote, user: user) }

	scenario 'from the guest home page' do
		visit home_path
		find(:css, '.quote').double_click
		expect(current_path).to eq "/quotes/#{quote.id}"
		expect(page).to have_content(quote.content)
		expect(page).to have_content('Discussion')
	end

	scenario "can get to a user's quote from a home page" do
		allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
		allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
		visit home_path
		find(:css, '.quote').double_click
		expect(current_path).to eq "/quotes/#{quote.id}"
		expect(page).to have_content(quote.content)
		expect(page).to have_content('Discussion')
	end
end

feature "Favoriting Quotes", :js => true do

	let!(:user) { create(:user) }
	
	scenario 'when a quote is not favorited' do
		allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
		allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
		user_quote = create(:quote)
    	user.quotes << user_quote
		visit home_path
		expect(page).to have_selector(".unliked-quote")
		find(".unliked-quote").click
		expect(page).to have_selector(".liked-quote")
		expect(page).to_not have_selector(".unliked-quote")
	end

	scenario 'when a quote is already favorited' do
		allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
		allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
		user_quote = create(:quote)
		user.quotes << user_quote
    	user.favorites << user_quote
		visit home_path
		expect(page).to have_selector(".liked-quote")
		find(".liked-quote").click
		expect(page).to have_selector(".unliked-quote")
		expect(page).to_not have_selector(".liked-quote")
	end

	scenario "when not logged in, no option to favorite or unfavorite" do
		allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(false)
		create(:quote)
		visit home_path
		expect(page).to_not have_selector(".liked-quote")
		expect(page).to_not have_selector(".unliked-quote")
	end
end