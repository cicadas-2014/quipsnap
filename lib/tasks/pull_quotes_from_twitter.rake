desc "Pulls quotes for each user in the background" 
task :pull_quotes_from_twitter => :environment do
	puts "Retrieving twitter amazon quotes for all users..."
  PullQuotesFromTwitter.new.perform
  puts "Done!"
end
