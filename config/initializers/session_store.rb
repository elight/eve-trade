# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_eve_trade_session',
  :secret      => '867a6f3d3275a62e82f8a9dec9738029a178c4cdf04e8a1adcf1bb7b8d03993268311deed0b9f89214ece8a0767258b65a5d3c29892b7fe78d56150706361c1b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
