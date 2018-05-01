class Batch < ApplicationRecord
	has_many :orders, dependent: :destroy
	
	validates_presence_of :reference, :purchase_channel
	validates_uniqueness_of :reference, :case_sensitive => false
end
