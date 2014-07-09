require 'rails_helper'

RSpec.describe BookclubsController, :type => :controller do

  describe 'GET #index' do 
    context "when visiting as a user" do
      before :each do
        user = create(:user)
        session[:user_id] = user.id
      end

      it "expects response to be successful" do
        get :index
        expect(response).to be_success
      end

      it "renders the :index template" do 
        get :index
        expect(response).to render_template("bookclubs/index")
      end

      it "assigns a new bookclub to @bookclub for the form" do
        get :index
        expect(assigns(:bookclub)).to be_a Bookclub
      end
    end

    context "when visiting as a guest user" do
      it "redirects to home path" do
        get :index
        expect(response).to redirect_to home_path
      end
    end
  end

  describe 'GET #all' do

    let(:bookclubs) { Bookclub.all }

    it "returns JSON-formatted bookclubs" do
      get :all
      expect(response.body).to have_content "You are being redirected"
    end
  end

  describe "POST #create" do

    before :each do
        user = create(:user)
        session[:user_id] = user.id
    end

    context "valid bookclub parameters" do
      it "expects response to be successful" do
        post :create, bookclub: attributes_for(:bookclub) 
        expect(response.status).to eq 200
      end

      it "creates a new bookclub" do
        expect{ post :create, bookclub: attributes_for(:bookclub) }.to change(Bookclub, :count).by(1)
      end
    end

    context "invalid bookclub parameters" do
      it "returns a 422 status" do
        post :create, bookclub: {name: nil}
        expect(response.status).to eq 422
      end

      it "does not create a new bookclub in the database" do
        expect{ post :create, bookclub: {name: nil} }.to change(Bookclub, :count).by(0)
      end
    end

  end

  describe "PUT #join" do

    let(:bookclub) { create(:bookclub) }
    let(:user) { create(:user) }

    before :each do
      session[:user_id] = user.id
    end

    it "expects response to be successful" do
      put :join, bookclub_id: bookclub.id
      expect(response.status).to eq 200
    end

    it "expects the bookclub users to increase by 1" do
      expect {
        put :join, bookclub_id: bookclub.id
      }.to change(bookclub.users, :count).by(1) 
    end

    it "returns JSON-formatted bookclub id" do
      put :join, bookclub_id: bookclub.id
      expect(response.body).to have_content (bookclub.id).to_json
    end

  end

  describe "DELETE #delete" do

    let!(:bookclub) { create(:bookclub) }

    it "expects bookclub count to decrease by 1" do
      expect {
        delete :delete, id: bookclub.id
      }.to change(Bookclub.all, :count).by(-1)
    end 

  end


end
