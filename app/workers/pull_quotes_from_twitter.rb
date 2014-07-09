### Background worker. See lib/tasks/pull_quotes_from_twitter.rake
class PullQuotesFromTwitter
  include ApplicationHelper
  include TwitterHelper

  def perform
    twitter_client
    encoder
    User.all.each { |user| create_quotes_from_twitter(user) if user.is_twitter }
  end

end