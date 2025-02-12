```sql
-- Users and Roles
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('admin', 'user')) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ
);

-- Financial Instruments (Managed by Admin)
CREATE TABLE instruments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('stock', 'crypto', 'forex')) NOT NULL,
    symbol VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Capital Movements
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(18, 8) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('deposit', 'withdraw')) NOT NULL,
    transaction_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trade Journal Entries
CREATE TABLE trades (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    instrument_id INT REFERENCES instruments(id),
    entry_price DECIMAL(18, 8) NOT NULL,
    quantity DECIMAL(18, 8) NOT NULL,
    stop_loss DECIMAL(18, 8),
    trade_type VARCHAR(10) CHECK (trade_type IN ('long', 'short')) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Trade Exits
CREATE TABLE trade_exits (
    id SERIAL PRIMARY KEY,
    trade_id INT REFERENCES trades(id) ON DELETE CASCADE,
    exit_price DECIMAL(18, 8) NOT NULL,
    quantity_exited DECIMAL(18, 8) NOT NULL,
    exit_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notes System (Polymorphic)
CREATE TABLE notes (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    action_type VARCHAR(20) CHECK (action_type IN ('transaction', 'trade', 'trade_exit')) NOT NULL,
    action_id INT NOT NULL,  -- References transactions/trades/trade_exits
    text TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Indexes for Common Queries
CREATE INDEX idx_trades_user ON trades(user_id);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_notes_action ON notes(action_type, action_id);
```