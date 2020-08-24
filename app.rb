
before do
  content_type :json
end

get '/orders' do
  Order.all.to_json
end

get '/check/:id' do |id|
  if Order.exists?(catalog_key: id)
    status 200
  else
    status 404
  end
end

post '/orders' do
  jwt = request.env['HTTP_AUTHORIZATION']
  token = jwt.match(/^Bearer\s+(.*)$/).captures.first
  claims = Rack::JWT::Token.decode(token, ENV['V4_JWT_KEY'], true, { algorithm: 'HS256' })
  params[:user_claims] = claims.first
  params[:jwt] = jwt
  order = Order.new(params)
  if order.save && order.submit_order
    status 201
    order.to_json
  else
    status 400
    {error: order.errors.full_messages.to_sentence}.to_json
  end
end

get '/healthcheck' do
  begin
  ActiveRecord::Base.connection
  postgres_healthy = ActiveRecord::Base.connected?
  return {postgres: {healthy: postgres_healthy}}.to_json

  rescue StandardError => e
    $logger.error e
    status 500
    return {postgres: {healthy: false, message: e.message}}.to_json
  end
end

get '/version' do
  buildtag = Dir.glob('buildtag*').first
  buildtag = if buildtag
    buildtag.gsub('buildtag.','')
  else
    'unknown'
  end

  return {
    build: buildtag
  }.to_json
end

