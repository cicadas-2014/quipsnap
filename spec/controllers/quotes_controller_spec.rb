require 'rails_helper'

RSpec.describe QuotesController, :type => :controller do
	describe "#search" do
		context "when searching for quotes" do
			let!(:quote) { create(:quote) }
			let!(:quote_2) { create(:quote) }

			it "expects response to be successful" do
				get :search
				expect(response).to be_success
			end

			it "renders the index page" do
				get :search
				expect(response).to render_template("users/index")
			end

			it "assigns @quotes to quotes" do
				get :search, q: {book_title_cont: quote.book.title, author_name_cont: quote.author.name, user_goodreads_name_cont: quote.user.goodreads_name}
				expect(assigns(:quotes)).to eq [quote] 
			end
			
		end
	end

	describe "post#favorite" do
		context "when adding quote as a favorite" do
			let!(:user) { create(:user) }
			let!(:quote) { create(:quote) }
			let!(:quote_favorite) { create(:quote_favorite) }

			it "saves quote to user's favorites" do
				allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
				post :favorite, id: quote.id				
				expect(assigns(:is_success)).to eq(true)
			end
		end
	end

	describe "delete#unfavorite" do
		context "when deleting quote from favorites" do
			let!(:user) { create(:user) }
			let!(:quote) { create(:quote) }
			let!(:quote_favorite) { create(:quote_favorite) }
			
			it "deletes quote from user's favorites" do
				allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(quote_favorite.user)
				delete :unfavorite, id: quote_favorite.quote.id				
				expect(assigns(:is_success)).to eq(true)				
			end		
		end
	end
end
