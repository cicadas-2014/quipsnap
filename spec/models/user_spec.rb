require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:user) { build(:user) }

  it "has a valid factory" do
    expect(user).to be_valid
  end

  it "is invalid without a goodreads_name" do
    expect(build(:user, goodreads_name: nil)).to have(1).errors_on(:goodreads_name)
  end

  it "is invalid without an auth_token" do
    expect(build(:user, auth_token: nil)).to have(1).errors_on(:auth_token)
  end

  it "is invalid without an auth_secret" do
    expect(build(:user, auth_secret: nil)).to have(1).errors_on(:auth_secret)
  end

  it "is invalid with a duplicate goodreads_name" do
    create(:user, goodreads_name: "abc")
    expect(build(:user, goodreads_name: "abc")).to have(1).errors_on(:goodreads_name)
  end

  it "has many quotes" do
    expect(user).to respond_to :quotes
  end
  
  it "has many comments" do
    expect(build(:user)).to respond_to :comments
  end

  it "only allows goodreads_name for ransackable attributes (quotes filter)" do
    expect(User.ransackable_attributes).to eq(["goodreads_name"])
  end

  it "has many owned_clubs" do
    expect(user).to respond_to :owned_clubs
  end

  it "has many favorite quotes" do
    expect(build(:user)).to respond_to :favorites
  end
end
