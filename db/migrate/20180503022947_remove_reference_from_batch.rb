class RemoveReferenceFromBatch < ActiveRecord::Migration[5.2]
  def change
  	remove_column :batches, :reference
  end
end
