```sql
CREATE TABLE trades (
    id SERIAL PRIMARY KEY,
    type VARCHAR(10) CHECK (type IN ('entry', 'exit')),
    parent_id INT, -- For exit->entry relationship
    entry_price DECIMAL(18,8),
    exit_price DECIMAL(18,8),
    quantity DECIMAL(18,8),
    quantity_exited DECIMAL(18,8),
    stop_loss DECIMAL(18,8)
);

```

| id | type | parent_id | entry_price | exit_price | quantity | quantity_exited | stop_loss |
|----|-------|-----------|-------------|------------|----------|-----------------|-----------|
| 1 | entry | NULL | 100.00 | NULL | 10 | NULL | 90.00 |
| 2 | exit | 1 | NULL | 110.00 | NULL | 3 | NULL |
| 3 | exit | 1 | NULL | 120.00 | NULL | 4 | NULL |
| 4 | exit | 1 | NULL | 105.00 | NULL | 2 | NULL |



```sql
   -- Get remaining quantity
   SELECT 
     t.quantity - COALESCE((
       SELECT SUM(quantity_exited) 
       FROM trades 
       WHERE parent_id = t.id
     ), 0) AS remaining
   FROM trades t
   WHERE t.type = 'entry';
```

-- Clean Entry Records
SELECT * FROM trades;
| id | entry_price | quantity | stop_loss |
|----|-------------|----------|-----------|
| 1  | 100.00      | 10       | 90.00     |

-- Explicit Exit Records
SELECT * FROM trade_exits;
| id | trade_id | exit_price | quantity_exited |
|----|----------|------------|-----------------|
| 1  | 1        | 110.00     | 3               |
| 2  | 1        | 120.00     | 4               |
| 3  | 1        | 105.00     | 2               |


```sql

   -- Remaining Quantity
   SELECT 
     t.quantity - COALESCE(SUM(te.quantity_exited), 0) AS remaining
   FROM trades t
   LEFT JOIN trade_exits te ON te.trade_id = t.id
   GROUP BY t.id;

```