class OrdersController < ApplicationController
	before_action :set_order, only: [:show, :update]
	# GET /orders
	def index
		@orders = Order.all
		@orders = Order.find_by_client_name(params[:client_name]) if params[:client_name].present?
		@orders = @orders.limit(params[:limit]) if params[:limit].present?
		@orders = @orders.offset(params[:offset]) if params[:offset].present?

		raise ActiveRecord::RecordNotFound.new(message: "Couldn't find Order") if @orders.blank?

		json_response(@orders)
	end

	# POST /orders
	def create
		@order = Order.create!(order_params)
		json_response(@order, :created)
	end

	# GET /orders/:id
	def show
		json_response(@order)
	end

	# PUT /orders/:id
	def update
		@order.update(order_params)
		head :no_content
	end

	private

	def order_params
		params.permit(:reference, :purchase_channel, :client_name, :address, :delivery_service, :line_items, :total_value, :status, :batch_id, :batch)
	end

	def set_order
		@order = Order.find(params[:id])
	end
end
