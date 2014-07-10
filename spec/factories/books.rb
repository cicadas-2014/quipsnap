FactoryGirl.define do
  factory :book do
  	title {Faker::Commerce.product_name}
  	image_url {Faker::Internet.url}
  end
end
