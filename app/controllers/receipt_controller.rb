class ReceiptController < ApplicationController
  def list
    @receipts = Receipt.all

    receipt_count = Receipt.count

    @exists_receipt = receipt_count > 0
  end

  def detail
    @receipt = Receipt.find(params[:id])
  end

  def create
    if params[:name] == nil
      return
    end

    if params[:name] != nil && params[:name] == ""
      redirect_to "/receipt/new", alert: "O nome deve ser preenchido"
      return
    end

    receipt = Receipt.new
    receipt.id = SecureRandom.uuid
    receipt.name = params[:name]
    receipt.user_id = session[:current_user_id]

    receipt.save

    redirect_to "/receipt"
  end
end
