require 'rails_helper'

RSpec.describe 'batches API', type: :request do
  # initialize test data
  let!(:batches) { create_list(:batch_with_orders, 10 ) }
  let(:batch_id) { batches.first.id }
  let(:batch_reference) { batches.first.reference}
  let(:batch_purchase_channel) { batches.first.purchase_channel}

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

  # Test suite for GET /batches/ by unique reference
  describe 'GET /batches/ by unique reference' do
    before { get "/batches/", params: {reference: batch_reference } }

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
    let(:order_1) { FactoryBot.create(:order, {purchase_channel: batch_purchase_channel, batch_id: batch_id}) }
    let(:order_2) { FactoryBot.create(:order, {purchase_channel: batch_purchase_channel, batch_id: batch_id}) }
    let(:order_3) { FactoryBot.create(:order, {purchase_channel: 'Other Channel', batch_id: batch_id}) }
    let(:valid_attributes) { {reference: '201803-54', purchase_channel: batch_purchase_channel, orders:  [order_1,order_2] }}

    context 'when the request is valid' do
      before { post '/batches', params: valid_attributes }

      it 'creates a batch' do
        expect(json['reference']).to eq('201803-54')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/batches', params: { purchase_channel: 'Other Channel' ,orders: [order_1,order_2,order_3] } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Reference can't be blank/)
      end
    end
  end

  # Test suite for PUT /todos/:id
  describe 'PUT /batches/:id' do
    let(:valid_attributes) { { reference: '201803-54' } }

    context 'when the record exists' do
      before { put "/batches/#{batch_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

end