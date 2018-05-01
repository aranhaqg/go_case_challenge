class CreateBatches < ActiveRecord::Migration[5.2]
  def change
    create_table :batches do |t|
      t.string :reference, null: false
      t.string :purchase_channel, null: false

      t.timestamps
    end
  end
end
