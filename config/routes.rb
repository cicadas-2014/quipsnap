Rails.application.routes.draw do
	mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

	root :to => "users#index", as: "home"

	get '/welcome' => "users#welcome", as: "welcome"

	get '/retrieve_quotes' => "users#retrieve_quotes"

	get '/sign_in' => "logging#sign_in"
	get '/sign_out' => "logging#sign_out"
	get '/auth' => "logging#auth" 

	get '/quotes/:id' => "quotes#show", as: "quote"
	get '/search' => "quotes#search", as: "quote_search"
	get '/search/category' => "quotes#search_by_category", as: "quote_search_category"

	get '/favorites' => "quotes#favorites", as: "favorites"
	post '/quotes/:id/favorite' => "quotes#favorite"
	delete '/quotes/:id/unfavorite' => "quotes#unfavorite"

	post '/quotes/comments/:comment_id/create' => "comments#create", as: "new_comment_reply"
	post '/quotes/:quote_id/comments/create' => "comments#create", as: "new_comment"
	get '/comments/replies' => "comments#get_replies"

	get '/bookclubs' => "bookclubs#index"
	post '/bookclubs/create' => "bookclubs#create"

	post '/bookclubs/:bookclub_id/quotes/:quote_id' => 'bookclubs#add_quote'
	delete '/bookclubs/:id/delete' => 'bookclubs#delete'

	get '/bookclubs/all' => "bookclubs#all"
	post '/bookclubs' => "bookclubs#create"

	get '/bookclubs/all' => "bookclubs#all"
	post '/bookclubs' => "bookclubs#create"
	get '/bookclubs/:bookclub_id' => 'bookclubs#show', as: "show_bookclub"
	put '/bookclubs/join' => "bookclubs#join"



end
