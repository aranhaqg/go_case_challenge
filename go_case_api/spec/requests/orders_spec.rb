require 'rails_helper'

RSpec.describe 'Orders API' do
	# Initialize the test data
	before(:all) do 
		Faker::UniqueGenerator.clear
	end 
	let!(:batch) { create(:batch) }
	let!(:orders) { create_list(:order, 5, batch_id: batch.id) }
	let(:batch_id) { batch.id }
	let(:order_id) { orders.first.id }
	let(:order_client_name) { orders.first.client_name }
	let(:order_purchase_channel) { orders.first.purchase_channel}
	let(:order_status) { orders.first.status}
	let(:order_limit) { 4 }
	let(:order_offset) { 2 }

	# Test suite for GET /orders/:id
	describe 'GET /orders/:id' do
	  before { get "/orders/#{order_id}" }

	  context 'when order exists' do
	    it 'returns status code 200' do
	      expect(response).to have_http_status(200)
	    end

	    it 'returns the order' do
	      expect(json['id']).to eq(order_id)
	    end
	  end

	  context 'when order does not exist' do
	    let(:order_id) { 0 }

	    it 'returns status code 404' do
	      expect(response).to have_http_status(404)
	    end

	    it 'returns a not found message' do
	      expect(response.body).to match(/Couldn't find Order/)
	    end
	  end
	end
	
	# Test suite for GET /order by batch
	describe 'GET /batches/:batch_id/orders' do
		before { get "/batches/#{batch_id}/orders" }

		context 'when batch exists' do
	  		it 'returns status code 200' do
	    		expect(response).to have_http_status(200)
	  		end

	  		it 'returns all batch items' do
	    		expect(json.size).to eq(5)
	  		end
		end

		context 'when batch does not exist' do
	  		let(:batch_id) { 0 }

	  		it 'returns status code 404' do
	    		expect(response).to have_http_status(404)
	  		end

	  		it 'returns a not found message' do
	    		expect(response.body).to match(/Couldn't find Batch/)
	  		end
		end
	end

	# Test suite for GET /orders/ by client_name
	describe 'GET /orders/ by client_name' do
	  	before { get "/orders/", params: {client_name: order_client_name } }

	  	context 'when the record exists' do
	    	it 'returns the orders' do
	      	expect(json).not_to be_empty
	      	expect(json['client_name']).to eq(order_client_name)
	    	end

	    	it 'returns status code 200' do
	      	expect(response).to have_http_status(200)
	    	end
	  	end

		context 'when the record does not exist' do
	    	let(:order_client_name) { '123456' }
	    	it 'returns status code 404' do
	      	expect(response).to have_http_status(404)
	    	end

	    	it 'returns a not found message' do
	      	expect(response.body).to match(/Couldn't find Order/)
	    	end
	  	end
	end

	# Test suite for GET /orders/ by an offset and limit
	describe 'GET /orders/ by an offset and limit' do
	  	before { get "/orders/", params: {offset: order_offset, limit: order_limit } }

	  	context 'when the record exists and is in range' do
	    	it 'returns the orders' do
	      	expect(json).not_to be_empty
	      	expect(json.size).to eq(3)
	    	end

	    	it 'returns status code 200' do
	      	expect(response).to have_http_status(200)
	    	end
	  	end

		context 'when the record exists and is not in range' do
	    	let(:order_offset) { 6 }
	    	let(:order_limit) { 0 }
	    	it 'returns status code 404' do
	      	expect(response).to have_http_status(404)
	    	end

	    	it 'returns a not found message' do
	      	expect(response.body).to match(/Couldn't find Order/)
	    	end
	  	end
	end

	# Test suite for GET /orders/ by purchase_channel and status
	describe 'GET /orders/ by purchase_channel and status' do
	  	before { get "/orders/", params: {purchase_channel: order_purchase_channel, status: order_status } }

	  	context 'when the record exists' do
	    	it 'returns the orders' do
	      	expect(json).not_to be_empty
	      	expect(json['purchase_channel']).to eq(order_purchase_channel)
	      	expect(json['status']).to eq(order_status)
	    	end

	    	it 'returns status code 200' do
	      	expect(response).to have_http_status(200)
	    	end
	  	end

		context 'when the record does not exist' do
	    	let(:order_purchase_channel) { '---' }
	    	let(:order_status) { '---' }
	    	it 'returns status code 404' do
	      	expect(response).to have_http_status(404)
	    	end

	    	it 'returns a not found message' do
	      	expect(response.body).to match(/Couldn't find Order/)
	    	end
	  	end
	end

	# Test suite for POST /orders
  	describe 'POST /orders' do
    	let(:valid_attributes) { 
    		{ 
	    		reference: 'BR102030',
				purchase_channel:  batch.purchase_channel ,
				client_name: 'Rogerinho',  
				address: 'Av Alvaro Correia, 595', 
				delivery_service: 'SEDEX',
				line_items:  [
					{sku: 'case-my-best-friend', model: 'iPhone X', case_type: 'Rose Leather'},
					{sku: 'powebank-sunshine', capacity: '10000mah'}
				].to_json,
				total_value: 120.00,
				batch_id: batch_id,
				status: 'ready'
    		} 
    	}
    	

		context 'when request attributes are valid' do
	      before { post "/orders", params: valid_attributes }

	      it 'returns status code 201' do
	        expect(response).to have_http_status(201)
	      end
		end

		context 'when an invalid request' do
			non_nullable_attributes =  ['reference', 'purchase_channel', 'client_name', 'address', 
	    		'delivery_service', 'line_items', 'total_value', 'status']
	    	
			non_nullable_attributes.each do |attribute|

		      context 'have an attribute non nullable missing' do
					before{ post "/orders", params: valid_attributes.except(attribute.intern) }
		      	it 'returns a failure message' do
		      		expect(response.body).to match("#{attribute.capitalize.gsub("_"," ")} can't be blank")
		      	end
		      	it 'returns status code 422' do
		        		expect(response).to have_http_status(422)
		      	end
				end
			end
		end
  	end

  	# Test suite for PUT /orders/:id
  	describe 'PUT /orders/:id' do
    	let(:valid_attributes) { { client_name: 'Renan' } }
    	context 'when the record exists' do
      	before { put "/orders/#{order_id}", params: valid_attributes }

      	it 'updates the record' do
      		updated_order = Order.find(order_id)
        		expect(updated_order.client_name).to match(/Renan/)
        		expect(response.body).to be_empty
      	end

      	it 'returns status code 204' do
        		expect(response).to have_http_status(204)
      	end
    	end
  	end
end