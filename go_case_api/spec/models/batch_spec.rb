require 'rails_helper'

# Test suite for the Batch model
RSpec.describe Batch, type: :model do
  # Association test
  # ensure Batch model has a 1:m relationship with the Order model
  it { should have_many(:orders).dependent(:destroy) }
  
  # Validation tests
  it { should validate_presence_of(:reference) }
  it { should validate_presence_of(:purchase_channel) }

  describe "uniqueness" do 
  	subject { 
      Batch.new(
        reference: '201803-54', 
        purchase_channel: 'Site BR')
    }
  	it { should validate_uniqueness_of(:reference).case_insensitive }
  end

  describe "invalid orders" do
    let(:order_1) {
      Order.new(
        reference: 'BR20180354' , 
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
      Order.new(
        reference: 'BR20180355' , 
        purchase_channel: 'Iguatemi Fortaleza', 
        client_name: 'Rogerinho', 
        address: 'Rua Paula Barros, 45', 
        delivery_service: 'SEDEX', 
        line_items: {sku: 'powebank-sunshine', capacity: '10000mah'}, 
        total_value: 120.00, 
        status: 'ready'
        )
    }
    subject { 
      Batch.new(
        reference: '201803-54', 
        purchase_channel: 'Site BR', 
        orders: [order_1,order_2]
      )  
    }
    it { should_not be_valid }
  end
end