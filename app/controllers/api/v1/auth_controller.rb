class API::V1::AuthController < API::V1Controller
  JWT_SECRET_KEY = OpenSSL::PKey::RSA.new(<<~PRIVATE_KEY
    -----BEGIN PRIVATE KEY-----
    #{ENV['JWT_SECRET_KEY']}
    -----END PRIVATE KEY-----
    PRIVATE_KEY
  )

  skip_before_action :authenticate_user!
  respond_to :json

  def login
    user = User.find_by(email: params[:email])
    if user && user.valid_password?(params[:password])
      render json: { data: {
        token: generate_token(user.id)
      }}, status: :ok
    else
      render json: { data: { errors: :unauthorized }}, status: :unauthorized
    end
  end

  protected

  def generate_token(user_id)
    payload = { id: user_id, exp: 30.minutes.from_now.to_i }
    JWT.encode(payload, JWT_SECRET_KEY, 'RS256')
  end
end
