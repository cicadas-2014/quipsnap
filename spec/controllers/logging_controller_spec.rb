require 'rails_helper'

RSpec.describe LoggingController, :type => :controller do

  describe "GET /auth" do

    it "redirects to the home page" do
      get :auth
      expect(response).to redirect_to home_path
    end

  end

end
