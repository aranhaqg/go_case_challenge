require 'rails_helper'

RSpec.describe 'batches API', type: :request do
  # initialize test data
  before(:each) do 
    Faker::UniqueGenerator.clear
  end 
  let!(:batches) { create_list(:batch_with_orders, 10 ) }
  let(:batch_id) { batches.first.id }
  let(:batch_reference) { batches.first.reference}
  let(:batch_purchase_channel) { batches.first.purchase_channel}
  let(:delivery_service) { batches.first.orders.first.delivery_service }

  # Test suite for GET /batches
  describe 'GET /batches' do
    # make HTTP get request before each example
    before { get '/batches'}

    it 'returns batches' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /batches/:id
  describe 'GET /batches/:id' do
    before { get "/batches/#{batch_id}" }

    context 'when the record exists' do
      it 'returns the batch' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(batch_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:batch_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Batch/)
      end
    end
  end

  # Test suite for GET /batches/ by reference
  describe 'GET /batches/ by reference' do
    before { 
      get "/batches/", params: {reference: batch_reference } 
    }

    context 'when the record exists' do
      it 'returns the batch' do
        expect(json).not_to be_empty
        expect(json['reference']).to eq(batch_reference)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:batch_reference) { 'jjjjj' }
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("Couldn't find Batch")
      end
    end
  end
  
  # Test suite for POST /batches
  describe 'POST /batches' do
    # valid payload
    let(:order_1) { 
      Order.create!(
        reference: 'BR20180358' , 
        purchase_channel: 'Site BR', 
        client_name: 'Renan', 
        address: 'Av Alvaro Correia 595', 
        delivery_service: 'PAC', 
        line_items: {sku: 'powebank-sunshine', capacity: '10000mah'}, 
        total_value: 120.00, 
        status: 'ready'
      )
    }
    let(:order_2) { 
      # FactoryBot.create(:order, {purchase_channel: batch_purchase_channel})
      order_2 = Order.create!(
        reference: 'BR20180359' , 
        purchase_channel: 'Site BR', 
        client_name: 'Rogerinho', 
        address: 'Rua Paula Barros, 45', 
        delivery_service: 'SEDEX', 
        line_items: {sku: 'powebank-sunshine', capacity: '10000mah'}, 
        total_value: 120.00, 
        status: 'ready'
      ) 
    }
    let(:order_3) { 
      # FactoryBot.create(:order, {purchase_channel: 'Other Channel'})
      order_2 = Order.create!(
        reference: 'BR20180360' , 
        purchase_channel: 'Other Channel', 
        client_name: 'Julinho', 
        address: 'Rua Dom Luis, 2500', 
        delivery_service: 'SEDEX', 
        line_items: {sku: 'powebank-sunshine', capacity: '10000mah'}, 
        total_value: 120.00, 
        status: 'ready'
      ) 
    }
    let(:valid_attributes) { 
      {
        purchase_channel: 'Site BR', 
        #orders: [order_1.attributes, order_2.attributes]
        order_ids: [order_1.id, order_2.id]
      }
    }

    context 'when the request is valid' do
      before { 
        post '/batches', params: valid_attributes 
      }

      it 'creates a batch' do
        expect(json['orders_count']).to eq(2)
        expect(json['reference']).to eq(Batch.last.reference)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when an invalid request' do
      non_nullable_attributes =  ['purchase_channel']
        
      non_nullable_attributes.each do |attribute|
          context 'have an attribute non nullable missing' do
          before{ post "/batches", params: valid_attributes.except(attribute.intern) }
          
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

  # Test suite for PUT /batches/:id
  describe 'PUT /batches/:id' do
    let(:valid_attributes) { { purchase_channel: 'Iguatemi store' } }
    let(:attributes_to_closing_batch) { { status: 'closing' }}
    let(:attributes_to_close_part_of_a_batch_for_delivery_service) { 
      { status: 'sent' , delivery_service: delivery_service }
    }
    context 'when the record exists' do
      before { put "/batches/#{batch_id}", params: valid_attributes }

      it 'updates the record' do
        updated_batch = Batch.find(batch_id)
        expect(updated_batch.purchase_channel).to match(/Iguatemi store/)
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the batch was produced change orders status to closing' do
      before { put "/batches/#{batch_id}", params: attributes_to_closing_batch }

      it 'updates the record' do
        updated_batch = Batch.find(batch_id)
        updated_batch.orders.each do |order|
          expect(order.status).to match(/closing/)
        end
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when part of the batch was closed by a delivery service change orders status to sent' do
      before { 
        put "/batches/#{batch_id}", 
        params: attributes_to_close_part_of_a_batch_for_delivery_service 
      }

      it 'updates the record' do
        updated_batch = Batch.find(batch_id)
        updated_orders = Array.new
        updated_orders << updated_batch.orders.find_by_delivery_service(delivery_service)
        updated_orders.each do |order|
          expect(Order.find(order.id).status).to match(/sent/)
        end
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

 
end