Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/", to: "page#home"

  get "/user/new", to: "user#create", as: :signup
  get "/login", to: "user#login", as: :login
  get "/logout", to: "user#destroy_session"

  get "/receipt", to: "receipt#list", as: :receipt_list
  post "/receipt", to: "receipt#create", as: :create_receipt
  get "/receipt/new", to: "receipt#create", as: :create_receipt_form
  get "/receipt/:id", to: "receipt#detail", as: :receipt_detail

  post "/income", to: "income#create", as: :create_income
  get "/income/new", to: "income#create", as: :create_income_form
end
