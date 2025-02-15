module Crypto
  JWT_PUBLIC_KEY = OpenSSL::PKey::RSA.new(<<~PUBLIC_KEY
    -----BEGIN PUBLIC KEY-----
    #{ENV["JWT_PUBLIC_KEY"]}
    -----END PUBLIC KEY-----
  PUBLIC_KEY
  )

  JWT_SECRET_KEY = OpenSSL::PKey::RSA.new(<<~PRIVATE_KEY
    -----BEGIN PRIVATE KEY-----
    #{ENV["JWT_SECRET_KEY"]}
    -----END PRIVATE KEY-----
  PRIVATE_KEY
  )
end
