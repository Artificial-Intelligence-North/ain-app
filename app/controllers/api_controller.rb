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

    user_id = data.first['id']
    exp = data.first['exp']

    if exp < Time.now.to_i
      render json: { data: { errors: :unauthorized }}, status: :unauthorized
    elsif User.find(user_id)
      @current_user = User.find(user_id)
    else
      render json: { data: { errors: :unauthorized }}, status: :unauthorized
    end
  rescue JWT::DecodeError
    render json: { data: { errors: :unauthorized }}, status: :unauthorized
  end
end
