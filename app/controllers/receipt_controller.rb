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
    receipt = Receipt.new
    receipt.id = SecureRandom.uuid
    receipt.name = "Lista de despesa 1"
    receipt.user_id = session[:current_user_id]

    receipt.save

    render :list
  end
end