class ExpenseController < ApplicationController
  def list
<<<<<<< Updated upstream

=======
  end

  def create
    expense = Expense.new
    expense.id = SecureRandom.uuid
    expense.name = "Lista de despesa 1"
    expense.user_id = session[:current_user_id]

    expense.save

    render :expense_list
>>>>>>> Stashed changes
  end
end
