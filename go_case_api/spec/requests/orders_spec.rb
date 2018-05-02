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
end