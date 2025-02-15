class APIController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_default_response_format
  before_action :set_content_type

  protected

  def set_content_type
    response.headers["Content-Type"] = "application/json; charset=utf-8"
  end

  def set_default_response_format
    request.format = :json
  end

  def authenticate_user!
    token = request.headers["Authorization"]&.split("Bearer ")&.last
    data = JWT.decode(token, Crypto::JWT_PUBLIC_KEY, true, { algorithm: "RS256" })
    JWT::Claims.verify_payload!(data, :exp)

    user_id = data&.first["id"]
    @current_user = User.find(user_id)
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { data: { errors: :unauthorized } }, status: :unauthorized
  end
end
