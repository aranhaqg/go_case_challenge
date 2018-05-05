module Api
  	module V1
		class ReportsController < ApplicationController
			# GET /reports
			def index
				@report_handler = ReportHandler.new(report_params)
				
				raise ActiveRecord::RecordNotFound.new(message: "Couldn't find orders") if (@report_handler.total_orders== 0)
				json_response(@report_handler.json_report)
			end

			private
			def report_params
				params.permit(:purchase_channel, :client_name).to_h
			end
		end
	end
end