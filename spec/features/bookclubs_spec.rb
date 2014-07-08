require 'rails_helper'

feature 'Show Bookclubs', :js => true do

  let!(:bookclub) {create(:bookclub)}
  let(:user) {create(:user)}

  scenario 'user logged in' do
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit home_path
    find('.nav-bookclubs').click
    expect(current_path).to eq('/bookclubs')
    expect(page).to have_content(bookclub.name)
    expect(page).to have_content(bookclub.description)
  end

  scenario 'user not logged in' do
    visit '/bookclubs'
    expect(current_path).to eq(home_path)
  end

end

feature 'Shows Bookclub Quotes', :js => true do 

  let!(:bookclub) {create(:bookclub)}
  let!(:quote) {create(:quote)}
  let!(:user) {create(:user)}

  scenario 'user does not belong to specific bookclub' do
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit home_path
    expect(page).to_not have_content(bookclub.name)
  end

  scenario 'user belongs to bookclub' do 
    user.bookclubs << bookclub
    bookclub.quotes << quote
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit home_path
    expect(page).to have_content(bookclub.name)
  end

  scenario 'user views bookclub quotes' do 
    user.bookclubs << bookclub
    bookclub.quotes << quote
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit home_path
    click_on bookclub.name
    expect(page).to have_content(quote.content)
  end  
end


feature 'Join Bookclubs', :js => true do
  let!(:bookclub) {create(:bookclub)}
  let(:user) {create(:user)}

  scenario 'is successful' do
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit bookclubs_path
    click_button "Join"
    wait_for_ajax_to_finish
    expect(page).to_not have_selector('bookclub-join');
  end

end

feature 'Add Bookclubs', :js => true do
  let(:bookclub) {build(:bookclub)}
  let(:user) {create(:user)}

  scenario 'with a valid bookclub' do
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit bookclubs_path
    find('#btn1').click
    fill_in 'Name', with: bookclub.name
    fill_in 'Description', with: bookclub.description
    find('input#submit').click
    wait_for_ajax_to_finish
    expect(page).to have_content(bookclub.name)
  end

  scenario 'with invalid bookclub' do
    bookclub = build(:bookclub, name: '')
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit bookclubs_path
    find('#btn1').click
    fill_in 'Name', with: bookclub.name
    fill_in 'Description', with: bookclub.description
    find('input#submit').click
    wait_for_ajax_to_finish
    expect(page).to_not have_content(bookclub.description)
  end


end