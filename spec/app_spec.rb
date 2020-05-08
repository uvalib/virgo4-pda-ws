require File.expand_path '../spec_helper.rb', __FILE__

describe "create ATO Order" do
  order_params = {
    catalog_key: 'u1234',
    computing_id: 'mst3k',
    hold_library: 'ALDERMAN',
    fund_code: 'test',
    loan_type: 'test'
  }

  it "should validate fields" do
    order = Order.create(order_params.without(:catalog_key))
    expect(order.errors).to be_present
  end

  it "should create an order" do
    order = Order.create(order_params)
    expect(order.errors).to be_empty
    expect(order.created_at).to be_present
  end
end