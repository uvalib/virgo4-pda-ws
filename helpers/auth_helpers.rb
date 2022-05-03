module AuthHelpers
  def jwt
    request.env['HTTP_AUTHORIZATION'] || halt(401)
  end

  def claims
    token = jwt.match(/^Bearer\s+(.*)$/).captures.first
    claims = Rack::JWT::Token.decode(token, ENV['V4_JWT_KEY'], true, { algorithm: 'HS256' })
    if claims.any?
      claims.first.symbolize_keys
    else
      return {}
    end

  rescue
    halt(401)
  end

  def authorize_admin
    unless %w(admin pdaadmin).include?(claims[:role])
      halt 401
    end
  end

  def authorize_order
    @order.jwt = jwt
    @order.user_claims = claims
  end

end