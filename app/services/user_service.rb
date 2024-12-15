class UserService
  class UserCreationError < StandardError; end

  def self.create_user(user_params)
    user = User.create!(user_params)
    user
  rescue StandardError => e
    Rails.logger.error("Order creation failed: #{e.message}")
    raise UserCreationError, e.message
  end

  def self.update_role(current_user, user, new_role)
    raise UserCreationError, "Current user not found" if current_user.nil?
    raise UserCreationError, "Current user is not authorized" unless %w[admin master].include?(current_user.role)

    user.update!(role: new_role)
    user
  rescue StandardError => e
    Rails.logger.error("Role update failed: #{e.message}")
    raise UserCreationError, e.message
  end
end
