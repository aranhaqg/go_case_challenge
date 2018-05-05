require 'rails_helper'

RSpec.describe 'Reports API' do
	# Initialize the test data
	before(:all) do 
		Faker::UniqueGenerator.clear
	end 
	let!(:batch) { create(:batch) }
	let!(:orders) { create_list(:order, 5, batch_id: batch.id, purchase_channel: batch.purchase_channel) }
	let(:batch_id) { batch.id }
	let(:order_id) { orders.first.id }
	let(:client_name) { orders.first.client_name }
	let(:purchase_channel) { batch.purchase_channel}
	# let(:order_status) { orders.first.status}
	# let(:limit) { 4 }
	# let(:offset) { 2 }

	# Test suite for GET /reports/
	describe 'GET /reports/' do
	  before { get "/reports/" }

	  context 'when reports exists' do
	    it 'returns status code 200' do
	    	expect(response).to have_http_status(200)
	    end

	    it 'returns all 5 orders for the defined purchase_channel' do
	      	expect(json['report'].size).to eq(1)
	      	expect(json['report'][0]['orders'].size).to eq(5)
	    end

	  end
	end
		
	# Test suite for GET /reports by purchase_channel
	describe 'GET /reports by purchase_channel' do
		before { get "/reports/", params: {purchase_channel: purchase_channel} }

		context 'when orders exists for the purchase_channel' do
	  		it 'returns status code 200' do

	    		expect(response).to have_http_status(200)
	  		end

	  		it 'returns all orders for purchase_channel' do
	    		expect(json['report'][0]['orders'].size).to eq(5)
	  		end
		end

		context "when there's no purchase_channel" do
	  		let(:purchase_channel) { 'Other Channel' }

	  		it 'returns status code 404' do
	    		expect(response).to have_http_status(404)
	  		end

	  		it 'returns a not found message' do
	    		expect(response.body).to match(/Couldn't find orders/)
	  		end
		end
	end
	
end