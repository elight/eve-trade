When /poll EVE for my (.+)$/ do |data_type|
  case data_type 
  when "transactions"
    Bot.wallet_journal(BOT_API_KEY, BOT_USER_ID, BOT_CHARACTER_ID)
  end
end
