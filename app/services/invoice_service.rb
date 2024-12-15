# app/services/invoice_service.rb
class InvoiceService
  def self.create_invoice(order, shipping, status: "pending", due_date: nil)
    ActiveRecord::Base.transaction do
      invoice = Invoice.create!(order_id: order.id, status: status, shipping_id: shipping.id,total_amount: order.total_price, due_date: due_date || 7.days.from_now)
      raise "unable to create payment" unless PaymentService.create_payment(invoice.id, order.total_price, "credit_card")
      invoice
    end
  end
  
  def self.update_status(invoice_id, status)
    invoice = Invoice.find(invoice_id)
    invoice.update!(status: status)
    invoice
  end
end
