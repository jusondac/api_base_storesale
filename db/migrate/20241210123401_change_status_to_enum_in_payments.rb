class ChangeStatusToEnumInPayments < ActiveRecord::Migration[8.0]
  def up
    add_column :payments, :status_temp, :integer, default: 0

    # Migrate existing string statuses to integers
    Payment.reset_column_information
    Payment.find_each do |payment|
      case payment.status
      when 'pending'
        payment.update_columns(status_temp: 0)
      when 'completed'
        payment.update_columns(status_temp: 1)
      when 'failed'
        payment.update_columns(status_temp: 2)
      end
    end

    remove_column :payments, :status
    rename_column :payments, :status_temp, :status
  end

  def down
    add_column :payments, :status_temp, :string

    # Migrate existing integer statuses back to strings
    Payment.reset_column_information
    Payment.find_each do |payment|
      case payment.status
      when 0
        payment.update_columns(status_temp: 'pending')
      when 1
        payment.update_columns(status_temp: 'completed')
      when 2
        payment.update_columns(status_temp: 'failed')
      end
    end

    remove_column :payments, :status
    rename_column :payments, :status_temp, :status
  end
end
