class Api::V2::PaymentsController < ApplicationController
  def index
    @payments = PaymentService.get_payments
    render json: @payments, status: :ok
  end
  
  def create
    payment = PaymentService.create_payment(params[:invoice_id], params[:amount], params[:payment_method])
    render json: { message: "Payment successful" }, status: :created
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def payment_params
    params.require(:payment).permit(:invoice_id, :amount, :status, :payment_date, :payment_method)
  end
end
