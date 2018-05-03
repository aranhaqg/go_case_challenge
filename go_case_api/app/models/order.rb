class Order < ApplicationRecord
  belongs_to :batch, optional: true
  scope :by_delivery_service, -> (delivery_service) { 
  	where(delivery_service: delivery_service) if delivery_service.present?
  }
  validates_presence_of :reference, :purchase_channel, :client_name, :address, :delivery_service, :line_items, :total_value, :status
  validates_uniqueness_of :reference, :case_sensitive => false
end
