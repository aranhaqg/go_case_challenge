class Batch < ApplicationRecord
	has_many :orders, dependent: :destroy, inverse_of: :batch, autosave: true
	
	attr_accessor :orders_ids
	

	validates_presence_of :purchase_channel
	# validates_uniqueness_of :reference, :case_sensitive => false

	validate :orders_must_have_same_purchase_channel, on: :create
	before_update :update_purchase_channel_of_orders, if: -> { self.purchase_channel_changed? }

	def reference
  		self[:reference]
	end
	def reference
		self.created_at.year.to_s + format('%02d', self.created_at.month) + "-"+ self.id.to_s
	end
	
	def self.find_by_reference(reference)

		Batch.find reference.partition("-").last
	end

	def orders_must_have_same_purchase_channel
		orders = Order.where(id: self.order_ids)
		orders.each do |order|
			if (order.purchase_channel != self.purchase_channel)
				errors.add(:base, 'Orders must have same purchase channel of the Batch')
				return
			end
		end
	end

	def update_purchase_channel_of_orders
		self.orders.each do |order|
			order.update_attribute(:purchase_channel, self.purchase_channel)
		end
	end

	def update_status(status)
		self.orders.each do |order|
			order.update_attribute(:status, status)
		end
	end

	def as_json(options = { })
	  h = super(options)
	  h[:reference]   = self.reference
	  h[:orders_count] = self.orders.count
	  h
	end
end
