# app/services/payment_service.rb
class PaymentService
  def self.get_payments
    payments = Payment.all
    payments
  end
  
  def self.create_payment(invoice_id, amount, method)
    ActiveRecord::Base.transaction do
      invoice = Invoice.find(invoice_id)
      Payment.create!( 
        invoice_id: invoice.id, 
        amount: amount, 
        payment_method: method, 
        payment_date: Time.current, 
        status: "pending"
      )
    end
  rescue => e
    raise "Payment failed: #{e.message}"
  end
end
