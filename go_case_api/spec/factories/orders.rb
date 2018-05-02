FactoryBot.define do
  factory :order, class: Order do
    reference { Faker::Code.unique.asin }
	purchase_channel { Faker::RickAndMorty.location} 
	client_name { Faker::RickAndMorty.character}  
	address { Faker::Address.street_address } 
	delivery_service { Faker::Lorem.word} 
	line_items {  
		[
			{sku: 'case-my-best-friend', model: 'iPhone X', case_type: 'Rose Leather'}, 
			{sku: 'powebank-sunshine', capacity: '10000mah'}
		]
	}
	total_value { Faker::Commerce.price}
	status {'ready'} 
	batch	
  end
end

