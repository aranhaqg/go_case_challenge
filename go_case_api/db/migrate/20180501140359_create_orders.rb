class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :reference, null: false
      t.string :purchase_channel, null: false
      t.string :client_name, null: false
      t.string :address, null: false
      t.string :delivery_service, null: false
      t.decimal :total_value, precision: 8, scale: 2, null: false
      t.json :line_items
      t.string :status, null: false
      t.references :batch, foreign_key: true

      t.timestamps
    end
  end
end
