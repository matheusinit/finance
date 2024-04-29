class IncomeController < ApplicationController
  def create
    name = params[:name]
    value = params[:value]
    is_monthly_recurring = params[:is_monthly_recurring]
    payment_date = params[:payment_date]

    if name == nil && value == nil && is_monthly_recurring == nil && payment_date == nil
      return
    end

    if name == ""
      redirect_to "/receipt/:id/income/new", alert: "O nome deve ser preenchido"
      return
    end

    if value == ""
      redirect_to "/receipt/:id/income/new", alert: "O valor deve ser preenchido"
      return
    end

    if payment_date == ""
      redirect_to "/receipt/:id/income/new", alert: "A data de pagamento deve ser definida"
      return
    end

    income = Income.new
    income.id = SecureRandom.uuid
    income.name = name
    income.value = value
    income.is_monthly_recurring = is_monthly_recurring == "yes" ? true : false
    income.payment_day = payment_date
    income.receipt_id = Receipt.all.limit(1).first().id

    income.save
  end
end
