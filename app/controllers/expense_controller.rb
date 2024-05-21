class ExpenseController < ApplicationController
  def create
    name = params[:name]
    value = params[:value]
    installments_number = params[:installments_number]
    payment_date = params[:payment_date]

    @receipt_id = params[:id]

    @receipt_name = Receipt.find(@receipt_id).name

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

  def edit
    @expense = Expense.find(params[:id])
    @receipt_id = @expense[:receipt_id]

    @receipt_name = Receipt.find(@expense[:receipt_id]).name

    name = params[:name]
    value = params[:value]
    installments_number = params[:installments_number]
    payment_day = params[:payment_date]

    if name == nil && value == nil && installments_number == nil && payment_day == nil
      return
    end
    if name != nil || name != ""
      @expense.name = name
    end

    if value != nil || value != 0
      @expense.value = value
    end

    if installments_number != nil || (installments_number != nil && installments_number >= 1)
      @expense.installments_number = installments_number
    end

    if payment_day != nil || (payment_day != nil && payment_day >= 1 && payment_day <= 31)
      @expense.payment_day = payment_day
    end

    @expense.save

    redirect_to "/receipt/#{@expense.receipt_id}"
  end

  def detail
    @receipt = Receipt.find(params[:id])

    @incomes = Income.where(receipt_id: params[:id])
    @expenses = Expense.where(receipt_id: params[:id])
  end

  def delete
    Expense.find(params[:id]).destroy
  end

  def mark_as_paid
    expense = Expense.find(params[:id])
    expense.is_paid = true

    expense.save
  end
end
