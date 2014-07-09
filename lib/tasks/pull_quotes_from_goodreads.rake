desc "Pulls quotes for each user in the background" 
task :pull_quotes_from_goodreads => :environment do
	puts "Retrieving quotes for all users..."
  PullQuotesFromGoodreads.new.perform
  puts "Done!"
end