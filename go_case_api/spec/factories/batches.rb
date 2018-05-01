FactoryBot.define do
  factory :batch do
    reference { Faker::Code.unique.asin }
		purchase_channel { Faker::RickAndMorty.location } 
		# association :orders #{ FactoryBot.create(:order, {purchase_channel: 'Other Channel', batch_id: batch_id}) }
  end
end
