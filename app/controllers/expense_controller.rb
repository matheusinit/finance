class ExpenseController < ApplicationController
  def create
    name = params[:name]
    value = params[:value]
    installments_number = params[:installments_number]
    payment_date = params[:payment_date]

    @receipt_id = params[:id]

    does_receipt_exists = Receipt.exists?(@receipt_id)

    if not does_receipt_exists
      redirect_to "/receipt"
    end

    if name == nil && value == nil && installments_number == nil && payment_date == nil
      return
    end

    create_expense_page_url = "/receipt/#{@receipt_id}/expense/new"

    if name == ""
      redirect_to create_expense_page_url, alert: "O nome deve ser preenchido"
      return
    end

    if value == ""
      redirect_to create_expense_page_url, alert: "O valor deve ser preenchido"
      return
    end

    if payment_date == ""
      redirect_to create_expense_page_url, alert: "A data de pagamento deve ser definida"
      return
    end

    expense = Expense.new
    expense.id = SecureRandom.uuid
    expense.name = name
    expense.value = value
    expense.installments_number = installments_number
    expense.is_paid = false
    expense.payment_day = payment_date
    expense.receipt_id = @receipt_id

    expense.save

    redirect_to "/receipt/#{@receipt_id}/expense/new"
  end
end
