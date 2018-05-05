class Order < ApplicationRecord
  belongs_to :batch, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: "created_by", optional: true

  scope :by_delivery_service, -> (delivery_service) { 
  	where(delivery_service: delivery_service) if delivery_service.present?
  }
  scope :by_purchase_channel, -> (purchase_channel) { 
  	where(purchase_channel: purchase_channel) if purchase_channel.present?
  }
  validates_presence_of :reference, :purchase_channel, :client_name, :address, :delivery_service, :line_items, :total_value, :status
  validates_uniqueness_of :reference, :case_sensitive => false

  def as_json(options = { })
	  h = super(options)
	  h[:total_value] = sprintf("%.2f", self.total_value)
	  h[:batch_reference]   = self.batch.reference if self.batch
	  h
	end
end
