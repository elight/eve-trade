# This is essentially a stubbing step faking out the real wallet journal results
When /^I get the following deposits:$/ do |transactions|
  transactions.hashes.each do |trans_data|
    Deposit.create_from trans_data
  end
end
