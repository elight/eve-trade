# This will guess the User class
require 'factory_girl/syntax/sham'

LEGAL_APIKEY_VALUES = Array(0..9) + Array('A'..'Z')
Sham.login { |n| "login#{n}" }
Sham.password { |n| "password#{n}" }
Sham.email { |n| "email#{n}@somewhere.com" }
Sham.character_id { |n| n }
Sham.character_name { |n| "character_name#{n}" }
Sham.stock_name { |n| "stock#{n}" }
Sham.symbol { |n| "S#{n}"}

Factory.define :eve_user, :class => User do |u|
  password = nil
  u.login { Sham.login }
  u.state 'active'
  u.password { password = Sham.password }
  u.email { Sham.email }
  u.password_confirmation { password }
  u.eve_character_id { Sham.character_id }
  u.eve_character_name { Sham.character_name }
end

Factory.define :ceo_user, :parent => :eve_user do |u|
  u.balance 55_000_000
end

Factory.define :bond do |b|
  b.name { Sham.stock_name }
  b.symbol { Sham.symbol }
  b.initial_price 42
  b.initial_interest_rate 5.0
  b.number_of_shares 50
  b.association :ceo, :factory => :ceo_user
  b.months_until_maturity 6
end

Factory.define :bond_share do |b|
  b.number 1
  b.user_id 2
  b.stock_id 1
end

Factory.define :stock, :class => InternalStock do |s|
  s.number_of_shares 1_000
  s.initial_price 1_000_000
  s.association :ceo, :factory => :ceo_user
  s.name { Sham.stock_name }
  s.symbol { Sham.symbol }
end
