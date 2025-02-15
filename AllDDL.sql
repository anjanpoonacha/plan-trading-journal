CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Core Tables with Notes Separation
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


CREATE TABLE journals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, name),  -- One journal name per user
    UNIQUE(user_id, id)  -- Add this to support the notes foreign key
); 

CREATE TABLE instruments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('stock', 'crypto', 'forex', 'future')),
    last_price NUMERIC(18, 8),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Unified Notes Table (Polymorphic Relationship)
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    noteable_type VARCHAR(20) NOT NULL CHECK (noteable_type IN ('trade_entry', 'trade_exit', 'fund')),
    noteable_id UUID NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(noteable_type, noteable_id),
    journal_id UUID NOT NULL REFERENCES journals(id) ON DELETE CASCADE,
    FOREIGN KEY (journal_id, noteable_id) 
    REFERENCES trade_entries(journal_id, id) ON DELETE CASCADE,
    FOREIGN KEY (journal_id, noteable_id) 
    REFERENCES trade_exits(journal_id, id) ON DELETE CASCADE,
    FOREIGN KEY (journal_id, noteable_id) 
    REFERENCES funds(journal_id, id) ON DELETE CASCADE
);

-- Trade Entities (Modified for Metric Calculations)
CREATE TABLE trade_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    instrument_id UUID NOT NULL REFERENCES instruments(id),
    direction VARCHAR(5) CHECK (direction IN ('LONG', 'SHORT')),
    quantity NUMERIC(18, 8) NOT NULL CHECK (quantity > 0),
    entry_price NUMERIC(18, 8) NOT NULL,
    stop_loss NUMERIC(18, 8),
    current_stop_loss NUMERIC(18, 8) GENERATED ALWAYS AS (
        COALESCE(current_stop_loss_override, stop_loss)
    ) STORED,
    current_stop_loss_override NUMERIC(18, 8),
	charges NUMERIC(18, 8) NOT NULL DEFAULT 0,
    entry_date TIMESTAMPTZ NOT NULL,
    journal_id UUID NOT NULL REFERENCES journals(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id, journal_id) REFERENCES journals(user_id, id),
    UNIQUE(id, journal_id),  -- Required for trade_exits foreign key
    
    -- Calculated Fields (Reference: metricsExplained/2.PositionMetrics.md lines 5-59)
    risk NUMERIC(18, 8) GENERATED ALWAYS AS (
        CASE direction
            WHEN 'LONG' THEN quantity * (entry_price - stop_loss)
            ELSE quantity * -(entry_price - stop_loss)
        END
    ) STORED,
    exposure NUMERIC(18, 8) GENERATED ALWAYS AS (quantity * entry_price) STORED
);

CREATE TABLE trade_exits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_id UUID NOT NULL REFERENCES trade_entries(id) ON DELETE CASCADE,
    exit_date TIMESTAMPTZ NOT NULL,
    exit_price NUMERIC(18, 8) NOT NULL,
    quantity_exited NUMERIC(18, 8) NOT NULL CHECK (quantity_exited > 0),
    charges NUMERIC(18, 8) NOT NULL DEFAULT 0,
    entry_price NUMERIC(18, 8) NOT NULL,
    journal_id UUID NOT NULL REFERENCES journals(id) ON DELETE CASCADE,
    FOREIGN KEY (entry_id, journal_id) REFERENCES trade_entries(id, journal_id),
    
    -- Modified calculated field to use local column
    gain_pct NUMERIC(18, 8) GENERATED ALWAYS AS (
        (exit_price - entry_price) / entry_price
    ) STORED
);

-- Funds with Validation (Reference: DataModelingFlow.md lines 126-129)
CREATE TABLE funds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    type VARCHAR(10) CHECK (type IN ('DEPOSIT', 'WITHDRAW')),
    amount NUMERIC(18, 8) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMPTZ NOT NULL,
    journal_id UUID NOT NULL REFERENCES journals(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id, journal_id) REFERENCES journals(user_id, id)
	-- ,
    -- CHECK (
    --     (type = 'WITHDRAW' AND amount <= (
    --         SELECT COALESCE(SUM(amount) FILTER (WHERE type = 'DEPOSIT'), 0) 
    --         - COALESCE(SUM(amount) FILTER (WHERE type = 'WITHDRAW'), 0) 
    --         FROM funds f 
    --         WHERE f.user_id = funds.user_id 
    --         AND f.transaction_date <= funds.transaction_date
    --     ))
    -- )
);
