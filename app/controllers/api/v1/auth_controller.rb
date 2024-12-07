class Api::V1::AuthController < ApplicationController
    before_action :authorize_request, only: [:auto_login]

    # Sign Up
    def signup
      user = User.new(user_params)
      if user.save
        render json: { message: 'User created successfully' }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # Login
    def login
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        token = JsonWebToken.encode(user_id: user.id)
        render json: { token: token, user: { id: user.id, email: user.email } }, status: :ok
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
  
    # Auto Login (optional, validates token)
    def auto_login
      render json: { user: @current_user }, status: :ok
    end
  
    private
  
    def user_params
      params.permit(:email, :password, :password_confirmation)
    end
  
    def authorize_request
      header = request.headers['Authorization']
      token = header.split(' ').last if header
      decoded = JsonWebToken.decode(token)
      @current_user = User.find_by(id: decoded[:user_id]) if decoded
      render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
    end
end
