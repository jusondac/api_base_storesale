class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    # skip_before_action :authorize_request, only: [:signup, :login]
    before_action :authorize_request

    private

    def authorize_request
      header = request.headers['Authorization']
      token = header.split(' ').last if header
      decoded = JsonWebToken.decode(token)
      @current_user = User.find_by(id: decoded[:user_id]) if decoded
      render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
    end

    def record_not_found(exception)
        render json: { error: "#{exception.model} not found" }, status: :not_found
    end
end
