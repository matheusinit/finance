class ExpenseController < ApplicationController
  def list
  end

  def create
    expense = Expense.new
    expense.id = SecureRandom.uuid
    expense.name = "Lista de despesa 1"
    expense.user_id = session[:current_user_id]

    expense.save

    render :list
  end
end
