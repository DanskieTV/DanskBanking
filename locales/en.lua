local Translations = {
    error = {
        not_enough_money = 'Not enough money in account',
        invalid_amount = 'Invalid amount specified',
    },
    success = {
        withdraw_success = 'Successfully withdrew $%{amount}',
        deposit_success = 'Successfully deposited $%{amount}',
    },
    info = {
        checking_balance = 'Current Balance: $%{amount}',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
}) 