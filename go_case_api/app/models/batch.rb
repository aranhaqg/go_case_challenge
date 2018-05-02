class Batch < ApplicationRecord
	has_many :orders, dependent: :destroy
	
	validates_presence_of :reference, :purchase_channel
	validates_uniqueness_of :reference, :case_sensitive => false

	validate :orders_must_have_same_purchase_channel

	def orders_must_have_same_purchase_channel
		if (self.orders.present? and 
			self.orders.where(purchase_channel: self.purchase_channel).count == self.orders.count)
			errors.add(:base, 'Orders must have same purchase channel of the Batch')
		end
	end
end
