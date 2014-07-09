require 'rails_helper'

RSpec.describe Bookclub, :type => :model do

  let(:bookclub) { build(:bookclub) }

  it "has a valid factory" do
    expect(bookclub).to be_valid
  end

  it "is invalid without a name" do
    expect(build(:bookclub, name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid without a description" do
    expect(build(:bookclub, description: nil)).to have(1).errors_on(:description)
  end

  it "cannot have a duplicate name" do
    create(:bookclub, name: "Reading Good")
    expect(build(:bookclub, name: "Reading Good")).to have(1).errors_on(:name)
  end

  it "belongs to an admin" do
    expect(bookclub).to respond_to :admin
  end

  it "has many memberships" do
    expect(bookclub).to respond_to :memberships
  end

  it "has many bookclub_quotes" do
    expect(bookclub).to respond_to :bookclub_quotes
  end

  it "has many quotes" do
    expect(bookclub).to respond_to :quotes
  end

  it "has many users" do
    expect(bookclub).to respond_to :users
  end

  it "is invalid with a bookclub name > 60 characters" do
    expect(build(:bookclub, name: "*"*61)).to have(1).errors_on(:name)
  end

  it "is valid with a bookclub name <= 60 characters" do
    expect(build(:bookclub, name: "*"*rand(1..60))).to be_valid
  end

end
