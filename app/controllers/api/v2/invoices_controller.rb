class Api::V2::InvoicesController < ApplicationController
  def index
    invoices = Invoice.all
    render json: invoices, status: :ok
  end

  def show
    invoice = Invoice.find_by(id: params[:id])
    return render json: { error: "Invoice not found" }, status: :not_found unless invoice

    render json: invoice, status: :ok
  end
end
