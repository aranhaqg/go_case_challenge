require 'rails_helper'

# Test suite for the Order model
RSpec.describe Order, type: :model do
  # Association test
  # ensure an Order record belongs to a single Batch record
  it { should belong_to(:batch) }
  
  # Validation test
  it { should validate_presence_of(:reference) }
  it { should validate_presence_of(:purchase_channel) }
  it { should validate_presence_of(:client_name) }
  it { should validate_presence_of(:address) }
  it { should validate_presence_of(:delivery_service) }
  it { should validate_presence_of(:line_items) }
  it { should validate_presence_of(:total_value) }
  it { should validate_presence_of(:status) }
  describe "uniqueness" do 
  	subject { Order.new(
  		reference: 'BR102030', 
  		purchase_channel: 'Site BR', 
  		client_name: 'Rogerio Lima', 
  		address: 'Rua Padre Valdevino, 2475 - Aldeota, Fortaleza - CE, 60135-041', 
  		delivery_service: 'SEDEX', 
  		line_items:  [{sku: 'case-my-best-friend', model: 'iPhone X', case_type: 'Rose Leather'}, {sku: 'powebank-sunshine', capacity: '10000mah'}],
  		total_value: 120.00,
  		status: 'ready' 
  		)}
  	it { should validate_uniqueness_of(:reference).case_insensitive }
  end
end