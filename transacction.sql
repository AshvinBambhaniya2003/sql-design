-- Savepoint 1: Initial point
SAVEPOINT Savepoint1;

-- Variables to store account balances
DECLARE sourceAccountBalance DECIMAL;
DECLARE destinationAccountBalance DECIMAL;

-- Set the account numbers and amount for the transfer
DO $$ 
DECLARE 
    sourceAccountNumber INT := 123456;
    destinationAccountNumber INT := 789012;
    transferAmount DECIMAL := 100.00;
BEGIN
    -- Retrieve current balances
    SELECT balance INTO sourceAccountBalance FROM accounts WHERE account_number = sourceAccountNumber;
    SELECT balance INTO destinationAccountBalance FROM accounts WHERE account_number = destinationAccountNumber;

    -- Check if the source account has sufficient balance
    IF sourceAccountBalance >= transferAmount THEN
        -- Savepoint 2: Before any updates
        SAVEPOINT Savepoint2;

        -- Debit from the source account
        UPDATE accounts SET balance = sourceAccountBalance - transferAmount WHERE account_number = sourceAccountNumber;

        -- Savepoint 3: After debit, before credit
        SAVEPOINT Savepoint3;

        -- Credit to the destination account
        UPDATE accounts SET balance = destinationAccountBalance + transferAmount WHERE account_number = destinationAccountNumber;

        -- Commit the transaction if everything is successful
        COMMIT;
        RAISE NOTICE 'Transaction successful!';
    ELSE
        -- Rollback to Savepoint 1 if the source account does not have sufficient balance
        ROLLBACK TO Savepoint1;
        RAISE EXCEPTION 'Transaction failed: Insufficient balance in the source account!';
    END IF;
END $$;
