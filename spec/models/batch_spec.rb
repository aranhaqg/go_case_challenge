require 'rails_helper'

# Test suite for the Batch model
RSpec.describe Batch, type: :model do
  # Association test
  # ensure Batch model has a 1:m relationship with the Order model
  it { should have_many(:orders).dependent(:destroy) }
  
  # Validation tests
  it { should validate_presence_of(:purchase_channel) }

  it "validates orders" do
    Order.delete_all
    order_1 = Order.create!(
      reference: 'BR20180354' , 
      purchase_channel: 'Site BR', 
      client_name: 'Renan', 
      address: 'Av Alvaro Correia 595', 
      delivery_service: 'PAC', 
      line_items: {sku: 'powebank-sunshine', capacity: '10000mah'}, 
      total_value: 120.00, 
      status: 'ready'
    )
    order_2 = Order.create!(
      reference: 'BR20180355' , 
      purchase_channel: 'Iguatemi Fortaleza', 
      client_name: 'Rogerinho', 
      address: 'Rua Paula Barros, 45', 
      delivery_service: 'SEDEX', 
      line_items: {sku: 'powebank-sunshine', capacity: '10000mah'}, 
      total_value: 120.00, 
      status: 'ready'
    )
    batch = Batch.new(purchase_channel: 'Site BR')
    batch.orders =  Order.where(id: [order_1.id,order_2.id])
    expect(batch).not_to be_valid

  end
      
end