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
		@batch = Batch.create!(batch_params)
		json_response(@batch, :created)
	end

	# GET /batches/:id
	def show
		json_response(@batch)
	end

	# PUT /batches/:id
	def update
		@batch.update(batch_params)
		head :no_content
	end

	# GET /batches/:id/orders
	def orders
		json_response(@batch.orders)	
	end

	private

	def batch_params
		params.permit(:reference, :purchase_channel, :orders)
	end

	def set_batch
		@batch = Batch.find(params[:id])
	end
end
