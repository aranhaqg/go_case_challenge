class ReportHandler
	attr_accessor :purchase_channel_collection, :purchase_channel, :total_orders, :json_report
	

	def initialize( attributes = {} )
		self.purchase_channel = attributes[:purchase_channel]
		self.purchase_channel_collection = Array.new
    	# If no purchase channel was given, just pick all orders grouped by the purchase channels registered
    	if self.purchase_channel.blank?
			self.purchase_channel_collection = Order.all.pluck(:purchase_channel).uniq
		else
			self.purchase_channel_collection << self.purchase_channel
		end
    	 
    	self.total_orders = 0
    	self.json_report = ({ report: report_hash}).to_json
  	end	


	def orders_hashes_collection(purchase_channel)
		orders_array = []
		orders_by_purchase_channel = Order.by_purchase_channel(purchase_channel)
		orders_by_purchase_channel.each do |order|  
			order_hash = order.attributes.merge!(
				batch_reference: order.batch.try(:reference)
			)
			order_hash.merge!("total_value" => sprintf("%.2f", order_hash["total_value"]))
			orders_array << order_hash
		end
		return orders_array
	end

	def report_hash
		report_hash_collection = []
		self.purchase_channel_collection.each do |channel|
			orders_collection = orders_hashes_collection(channel)
			report_element_hash = Hash.new
			report_element_hash.merge!(purchase_channel: channel)
			report_element_hash.merge!(orders: orders_collection)
			report_element_hash.merge!(orders_count: orders_collection.count)
			self.total_orders += orders_collection.count
			report_element_hash.merge!(orders_total_value: orders_collection.map{|o| o["total_value"].to_f}.reduce(:+).to_s)
			report_hash_collection << report_element_hash
		end

		return report_hash_collection
		
	end
	
end