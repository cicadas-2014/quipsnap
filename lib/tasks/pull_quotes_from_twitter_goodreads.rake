desc "Pulls quotes for each user in the background" 
task :pull_quotes_from_twitter_goodreads => :environment do
	puts "Retrieving twitter goodreads quotes for all users..."
  PullQuotesFromTwitterGoodreads.new.perform
  puts "Done!"
end
