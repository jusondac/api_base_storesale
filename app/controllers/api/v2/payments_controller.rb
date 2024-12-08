class Api::V2::PaymentsController < ApplicationController
  def create
    payment = Payment.new(payment_params)

    if payment.save
      render json: payment, status: :created
    else
      render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:invoice_id, :amount, :status, :payment_date, :payment_method)
  end
end
