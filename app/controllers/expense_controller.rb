class ExpenseController < ApplicationController
  def list
    @expenses = Expense.all

    expense_count = Expense.count

    @exists_expense = expense_count > 0
  end

  def detail
    @expense = Expense.find(params[:id])
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
