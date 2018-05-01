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
  	subject { Batch.new(reference: '201803-54', purchase_channel: 'Site BR')}
  	it { should validate_uniqueness_of(:reference).case_insensitive }
  end
end