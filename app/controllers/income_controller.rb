class IncomeController < ApplicationController
  def create
    name = params[:name]
    value = params[:value]
    is_monthly_recurring = params[:is_monthly_recurring]
    payment_date = params[:payment_date]
    @receipt_id = params[:id]

    @receipt_name = Receipt.find(@receipt_id).name

    does_receipt_exists = Receipt.exists?(@receipt_id)

    if not does_receipt_exists
      redirect_to "/receipt"
    end

    if name == nil && value == nil && is_monthly_recurring == nil && payment_date == nil
      return
    end

    create_income_page_url = "/receipt/#{@receipt_id}/income/new"

    if name == ""
      redirect_to create_income_page_url, alert: "O nome deve ser preenchido"
      return
    end

    if value == ""
      redirect_to create_income_page_url, alert: "O valor deve ser preenchido"
      return
    end

    if payment_date == ""
      redirect_to create_income_page_url, alert: "A data de pagamento deve ser definida"
      return
    end

    income = Income.new
    income.id = SecureRandom.uuid
    income.name = name
    income.value = value
    income.is_monthly_recurring = is_monthly_recurring == "yes" ? true : false
    income.is_paid = false
    income.payment_day = payment_date
    income.receipt_id = @receipt_id

    income.save

    redirect_to create_income_page_url
  end

  def edit
    @income = Income.find(params[:id])
    @receipt_id = @income[:receipt_id]

    @receipt_name = Receipt.find(@income[:receipt_id]).name

    name = params[:name]
    value = params[:value]
    is_monthly_recurring = params[:is_monthly_recurring]
    payment_day = params[:payment_date]

    if name == nil && value == nil && is_monthly_recurring == nil && payment_day == nil
      return
    end

    if name != nil || name != ""
      @income.name = name
    end

    if value != nil || value != 0
      @income.value = value
    end

    if is_monthly_recurring != nil || is_monthly_recurring != @income.is_monthly_recurring
      @income.is_monthly_recurring = is_monthly_recurring
    end

    if payment_day != nil || (payment_day != nil && payment_day >= 1 && payment_day <= 31)
      @income.payment_day = payment_day
    end

    @income.save

    redirect_to "/receipt/#{@income.receipt_id}"
  end

  def detail
    @receipt = Receipt.find(params[:id])

    @incomes = Income.where(receipt_id: params[:id])
    @expenses = Expense.where(receipt_id: params[:id])
  end

  def mark_as_paid
    income = Income.find(params[:id])
    income.is_paid = true

    income.save
  end

  def delete
    income = Income.find(params[:id])
    income.destroy

    redirect_to "/receipt/#{income.receipt_id}"
  end
end
