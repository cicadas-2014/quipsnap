require 'faker'

# Create a couple of authors, books
5.times do
  Author.create(name: Faker::Name.name)
  Book.create(title: Faker::Commerce.product_name)
end

# Create a couple of users
5.times do
  user = User.create(goodreads_name: Faker::Internet.user_name, 
                    auth_token: Faker::Lorem.characters(10), 
                    auth_secret: Faker::Lorem.characters(10)
                    )

  # Add quotes for these users
  5.times do |i|
    user.quotes << Quote.create(content: Faker::Lorem.sentence(15), 
                                author_id: Author.find(i+1).id, 
                                book_id: Book.find(i+1).id,
                                goodreads_link: "link #{i}"
                                )
  end
end

# Create a couple of bookclubs
bc = Bookclub.create(name: Faker::Commerce.product_name, description: Faker::Lorem.sentence, user_id: User.first)
bc_2 = Bookclub.create(name: Faker::Commerce.product_name, description: Faker::Lorem.sentence, user_id: User.last)


# Add users to bookclub
bc.users << User.all
bc_2.users << User.limit(3)

# Add some quotes in the bookclubs
bc.quotes << Quote.limit(2)
bc_2.quotes << Quote.limit(3)

# Create comments
5.times do |i|
  Comment.create(content: Faker::Lorem.sentence, user_id: User.find(i+1).id)
end

# Add comments to quotes
Quote.first.comments << Comment.limit(3)
Quote.last.comments << Comment.limit(4)
