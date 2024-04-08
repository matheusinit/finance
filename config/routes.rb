Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/user/new", to: 'user#create', as: :signup
  get "/login", to: 'user#login', as: :login
  get "/expense", to: 'expense#list', as: :expense_list
<<<<<<< Updated upstream
=======
  post '/expense', to: 'expense#create', as: :create_expense
  get '/logout', to: 'user#destroy_session'
>>>>>>> Stashed changes
  # Defines the root path route ("/")
  # root "posts#index"
end
