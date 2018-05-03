class BatchesController < ApplicationController
	before_action :set_batch, only: [:show, :update, :orders]

	# GET /batches
	def index
		@batches = Batch.all
		@batches = Batch.find_by_reference(params[:reference]) if params[:reference].present?
		raise ActiveRecord::RecordNotFound.new(message: "Couldn't find Batch") if @batches.nil?

		json_response(@batches)
	end

	# POST /batches
	def create
		@batch = Batch.new(purchase_channel: params[:purchase_channel] )
		@batch.orders =  Order.where(id: params[:order_ids]) 
		@batch.save!
		json_response({reference: @batch.reference, orders_count: @batch.orders.count}, :created)
	end

	# GET /batches/:id
	def show
		json_response(@batch)
	end

	# PUT /batches/:id
	def update
		
		@batch.update(batch_params)
		@batch.update_status(params[:status]) if params[:status].present?

		head :no_content
	end

	# GET /batches/:id/orders
	def orders
		json_response(@batch.orders)	
	end

	private

	def batch_params
		params.permit(:reference, :purchase_channel, :order_ids)
	end

	def set_batch
		@batch = Batch.find(params[:id])
	end

end
