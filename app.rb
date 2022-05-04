
require 'sinatra/json'
before do
  content_type :json
end

helpers EmailHelpers, AuthHelpers

get '/orders' do
  authorize_admin
  @orders = Order.order('id desc').page(params[:page])
  json ({
    orders: @orders,
    pagination: {
      current_page: @orders.current_page,
      next_page: @orders.next_page,
      prev_page: @orders.prev_page,
      total_pages: @orders.total_pages,
      total_count: @orders.total_count
    }
  })
end

get '/check/:id' do |id|
  if Order.where(catalog_key: id).where("vendor_order_number IS NOT NULL").exists?
    status 200
  else
    status 404
  end
end

post '/orders' do
  @order = Order.find_or_initialize_by(params)
  authorize_order

  if @order.save && @order.submit_order
    send_confirmation_email
    status 201
    @order.to_json
  else
    status 400
    {error: @order.errors.full_messages.to_sentence}.to_json
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

