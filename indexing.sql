-- Index for journal_id (used in joins and filters)
CREATE INDEX idx_unified_journal ON unified_trade_metrics(journal_id);

-- Index for user_id (if used in queries)
CREATE INDEX idx_unified_user ON unified_trade_metrics(user_id);

-- Index for instrument_id (if used in queries)
CREATE INDEX idx_unified_instrument ON unified_trade_metrics(instrument_id);

-- Composite index for journal_id and entry_date (if filtering by date)
CREATE INDEX idx_unified_journal_entry_date ON unified_trade_metrics(journal_id, entry_date);

-- Index for exit_records (if querying JSONB fields)
CREATE INDEX idx_unified_exit_records ON unified_trade_metrics USING GIN (exit_records);

-- Index for journal_id (used in joins)
CREATE INDEX idx_trade_entries_journal ON trade_entries(journal_id);

-- Index for instrument_id (used in joins)
CREATE INDEX idx_trade_entries_instrument ON trade_entries(instrument_id);

-- Composite index for journal_id and entry_date (if filtering by date)
CREATE INDEX idx_trade_entries_journal_entry_date ON trade_entries(journal_id, entry_date);

-- Index for entry_id (used in joins)
CREATE INDEX idx_trade_exits_entry ON trade_exits(entry_id);

-- Index for journal_id (used in joins)
CREATE INDEX idx_trade_exits_journal ON trade_exits(journal_id);

-- Composite index for journal_id and exit_date (if filtering by date)
CREATE INDEX idx_trade_exits_journal_exit_date ON trade_exits(journal_id, exit_date);

-- Index for journal_id (used in joins)
CREATE INDEX idx_funds_journal ON funds(journal_id);

-- Composite index for journal_id and transaction_date (if filtering by date)
CREATE INDEX idx_funds_journal_transaction_date ON funds(journal_id, transaction_date);

-- Index for id (used in joins)
CREATE INDEX idx_instruments_id ON instruments(id);

-- Index for symbol (if querying by symbol)
CREATE INDEX idx_instruments_symbol ON instruments(symbol);
