class AddBarcodeToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :barcode, :string
  end
end
