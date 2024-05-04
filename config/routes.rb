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

  post "/receipt/:id/income", to: "income#create", as: :create_income
  get "/receipt/:id/income/new", to: "income#create", as: :create_income_form
  put "/income/:id/payment", to: "income#mark_as_paid", as: :mark_income_as_paid

  post "/receipt/:id/expense", to: "expense#create", as: :create_expense
  get "/receipt/:id/expense/new", to: "expense#create", as: :create_expense_form
  put "/expense/:id/payment", to: "expense#mark_as_paid", as: :mark_expense_as_paid
end
