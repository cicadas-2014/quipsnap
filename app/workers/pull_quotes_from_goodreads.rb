### Background worker. See lib/tasks/pull_quotes_from_goodreads.rake
class PullQuotesFromGoodreads
  include ApplicationHelper

  def perform
    User.all.each { |user| get_quotes(user) }
  end

end