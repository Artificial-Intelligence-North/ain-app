class APIController < ApplicationController
  JWT_PUBLIC_KEY = OpenSSL::PKey::RSA.new(<<~PUBLIC_KEY
    -----BEGIN PUBLIC KEY-----
    #{ENV['JWT_PUBLIC_KEY']}
    -----END PUBLIC KEY-----
    PUBLIC_KEY
  )

  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  protected

  def authenticate_user!
    token = request.headers['Authorization']&.split('Bearer ')&.last
    data = JWT.decode(token, JWT_PUBLIC_KEY, true, { algorithm: 'RS256' })
    JWT::Claims.verify_payload!(data, :exp)

    user_id = data&.first['id']
    @current_user = User.find(user_id)

  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { data: { errors: :unauthorized }}, status: :unauthorized
  end
end
