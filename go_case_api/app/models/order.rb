class Order < ApplicationRecord
  belongs_to :batch, optional: true

  validates_presence_of :reference, :purchase_channel, :client_name, :address, :delivery_service, :line_items, :total_value, :status
  validates_uniqueness_of :reference, :case_sensitive => false
end
