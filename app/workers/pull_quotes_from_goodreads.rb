### Background worker. See lib/tasks/pull_quotes_from_goodreads.rake
class PullQuotesFromGoodreads
  include ApplicationHelper
  include TwitterHelper

  def perform
    User.all.each do |user|
    	if user.is_twitter 
    		create_quotes_from_twitter(user)
    	else
    		get_quotes(user)
    	end
    end
  end

end