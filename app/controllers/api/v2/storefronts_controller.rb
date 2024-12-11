class Api::V2::StorefrontsController < ApplicationController
  before_action :authorize_request
  before_action :set_storefront, only: [:show, :update, :destroy]

  # GET /api/v2/storefronts
  def index
    @storefronts = @current_user.storefronts
    render json: @storefronts, status: :ok
  end

  # GET /api/v2/storefronts/:id
  def show
    render json: @storefront, status: :ok
  end

  # POST /api/v2/storefronts
  def create
    @storefront = Storefront.new(storefront_params.merge(user: @current_user))
    raise @storefront.errors.full_messages unless @storefront.save
    # byebug unless @storefront.save
    render json: @storefront, status: :created
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PATCH/PUT /api/v2/storefronts/:id
  def update
    if @storefront.update(storefront_params)
      render json: @storefront, status: :ok
    else
      render json: { errors: @storefront.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v2/storefronts/:id
  def destroy
    @storefront.destroy
    head :no_content
  end

  private

  def set_storefront
    @storefront = @current_user.storefronts.find_by(id: params[:id])
    render json: { error: "Storefront not found" }, status: :not_found unless @storefront
  end

  def storefront_params
    params.require(:storefront).permit(:name, :user_id, :city, :address)
  end
end
