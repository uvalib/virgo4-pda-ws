class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string 'isbn'
      t.string 'catalog_key'
      t.string 'computing_id'
      t.string 'hold_library'
      t.string 'fund_code'
      t.string 'loan_type'
      t.string 'vendor_order_number'
      t.timestamps
    end
  end
end
