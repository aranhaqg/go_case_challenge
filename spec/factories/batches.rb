FactoryBot.define do
  factory :batch do
	purchase_channel { Faker::RickAndMorty.location } 
	
	factory :batch_with_orders do
		transient do 
			orders_count 2
		end
		after(:create) do |batch, evaluator|
			create_list(:order, evaluator.orders_count, batch: batch)
			
		end
	end

  end
end
