require File.expand_path '../spec_helper.rb', __FILE__

describe "create ATO Order", type: :controller do
  order_params = {
    catalog_key: 'u1234',
    computing_id: 'mst3k',
    hold_library: 'ALDERMAN',
    fund_code: 'test',
    loan_type: 'test',
    isbn: '1234',
    barcode: '1234'
  }

  let(:order) { Order.new(order_params) }
  before do
    order.user_claims = jwt_claims
  end

  it "should validate fields" do
    order.catalog_key = nil
    order.save
    expect(order.errors).to be_present
  end

  it "should create an order" do
    order.save

    expect(order.errors).to be_empty
    expect(order.created_at).to be_present
  end

end

describe "list orders for admins", type: :controller do
  it "authorizes JWT" do
    env 'HTTP_AUTHORIZATION', generate_jwt(role: 'admin')
    expect(get('/orders').status).to be 200
  end

  it "rejects missing JWT" do
    expect( get('/orders').status ).to be 401
  end

  it "returns orders" do
    env 'HTTP_AUTHORIZATION', generate_jwt(role: 'admin')
    parsed = JSON.parse(get('/orders').body)
    expect(parsed.keys).to eq %w(orders pagination)
  end
end