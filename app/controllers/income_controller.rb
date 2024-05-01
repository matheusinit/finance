class IncomeController < ApplicationController
  def create
    name = params[:name]
    value = params[:value]
    is_monthly_recurring = params[:is_monthly_recurring]
    payment_date = params[:payment_date]
    @receipt_id = params[:id]

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
    income.payment_day = payment_date
    income.receipt_id = @receipt_id

    income.save

    redirect_to create_income_page_url
  end
end
