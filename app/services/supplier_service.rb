# app/services/supplier_service.rb
class SupplierService
  def self.create_supplier(name, email, phone, address)
    Supplier.create!(
      name: name,
      email: email,
      phone_number: phone,
      address: address
    )
  end

  def self.update_supplier(supplier_id, attributes)
    supplier = Supplier.find(supplier_id)
    supplier.update!(attributes)
    supplier
  end

  def self.get_supplier(supplier_id)
    Supplier.find(supplier_id)
  end
end
