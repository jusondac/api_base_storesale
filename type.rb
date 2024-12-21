user, enum :role, [:master, :admin, :customer, :vendor]
payment, enum :status, [:pending, :completed, :failed]
validates :status, inclusion: { in: %w[pending completed canceled processing] }
validates :status, inclusion: { in: %w[pending paid overdue] }
