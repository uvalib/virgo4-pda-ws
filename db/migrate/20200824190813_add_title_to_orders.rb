class AddTitleToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :title, :string
  end
end
