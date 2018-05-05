FactoryBot.define do
  factory :user do
    name { Faker::RickAndMorty.character }
    email 'foo@bar.com'
    password 'foobar'
  end
end