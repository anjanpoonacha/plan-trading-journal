
INSERT INTO users (id, email, created_at)
VALUES (
  '5ae44820-be78-44e1-92c4-449828bb82ad',
  'placeholder@example.com',
  NOW()
);


INSERT INTO journals (id, user_id, name, created_at)
VALUES (
  'cd03b578-8769-47db-a51d-be9be4584bac',
  '5ae44820-be78-44e1-92c4-449828bb82ad',
  'India',
  '2024-02-15 05:34:11'
);


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'f0dfcd69-d862-431b-aa2c-935da4f87f6c',
  'SYM-f0dfcd69',
  'Instrument f0dfcd69',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '488d8686-0a44-4017-bf23-a3fccde2bdbc',
  'SYM-488d8686',
  'Instrument 488d8686',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'ede01cfe-f78a-43ca-9d89-08f36b9a6512',
  'SYM-ede01cfe',
  'Instrument ede01cfe',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '45fd1dee-0909-4f1f-9646-ff5e0c24763e',
  'SYM-45fd1dee',
  'Instrument 45fd1dee',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'b04518de-f340-43d8-a5ba-2bb3b24cd509',
  'SYM-b04518de',
  'Instrument b04518de',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id, charges
) VALUES (
  '80f85cc2-5ebd-4bb4-a800-483c2ca88fb7',
  '5ae44820-be78-44e1-92c4-449828bb82ad',
  'f0dfcd69-d862-431b-aa2c-935da4f87f6c',
  'LONG',
  200,
  100,
  90,
  '2024-01-01 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac',
  48.38
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '37818e74-1184-4a8e-9402-5ab8155a9821',
  '80f85cc2-5ebd-4bb4-a800-483c2ca88fb7',
  '2024-02-01 00:00:00',
  150,
  50,
  31.53,
  100,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '228e404d-fa63-41a9-bb3d-80b4402f3f07',
  '80f85cc2-5ebd-4bb4-a800-483c2ca88fb7',
  '2024-02-25 00:00:00',
  200,
  50,
  58.91,
  100,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '0e165260-88e8-4b03-a2f9-ccc52ef2d409',
  '80f85cc2-5ebd-4bb4-a800-483c2ca88fb7',
  '2025-02-14 00:00:00',
  100,
  100,
  26.32,
  100,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id, charges
) VALUES (
  '1a39169f-2986-45a9-8c9f-e3f2b9c918d7',
  '5ae44820-be78-44e1-92c4-449828bb82ad',
  '488d8686-0a44-4017-bf23-a3fccde2bdbc',
  'LONG',
  100,
  100,
  90,
  '2024-01-02 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac',
  12.39
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '672ede18-40db-458e-9ba5-a9ccf5c4a31d',
  '1a39169f-2986-45a9-8c9f-e3f2b9c918d7',
  '2024-01-16 00:00:00',
  120,
  20,
  18.02,
  100,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '869a5554-2c4f-48dd-a475-51e7520f3656',
  '1a39169f-2986-45a9-8c9f-e3f2b9c918d7',
  '2024-02-20 00:00:00',
  90,
  80,
  23.21,
  100,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id, charges
) VALUES (
  '53c9d428-8e73-4317-9412-8402513d3647',
  '5ae44820-be78-44e1-92c4-449828bb82ad',
  'ede01cfe-f78a-43ca-9d89-08f36b9a6512',
  'SHORT',
  100,
  100,
  105,
  '2024-12-01 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac',
  23.84
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '7489e587-8bc9-4c84-96d8-a7cfdd7a47ea',
  '53c9d428-8e73-4317-9412-8402513d3647',
  '2025-02-14 00:00:00',
  80,
  20,
  0.04,
  100,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '4557a905-3fad-40e5-b2fb-d39abcd7c118',
  '53c9d428-8e73-4317-9412-8402513d3647',
  '2025-02-01 00:00:00',
  80,
  20,
  11.84,
  100,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'f6ddccf5-c276-4862-8aec-20edd9eb2472',
  '53c9d428-8e73-4317-9412-8402513d3647',
  '2025-01-29 00:00:00',
  100,
  60,
  1.14,
  100,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id, charges
) VALUES (
  'bf775567-5da5-43ff-9e12-33f9cf4e812c',
  '5ae44820-be78-44e1-92c4-449828bb82ad',
  '45fd1dee-0909-4f1f-9646-ff5e0c24763e',
  'SHORT',
  100,
  100,
  105,
  '2025-02-14 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac',
  118.24
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id, charges
) VALUES (
  '0474a005-8bdb-4141-b972-83d35c2ea5f0',
  '5ae44820-be78-44e1-92c4-449828bb82ad',
  'b04518de-f340-43d8-a5ba-2bb3b24cd509',
  'LONG',
  100,
  100,
  98,
  '2025-02-14 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac',
  12.39
);


INSERT INTO funds (
  id, user_id, type, amount, transaction_date, 
  journal_id
) VALUES (
  'a034ae79-d38f-4c37-a16f-e37812706fa2',
  '5ae44820-be78-44e1-92c4-449828bb82ad',
  'DEPOSIT',
  100000,
  '2024-01-01 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO funds (
  id, user_id, type, amount, transaction_date, 
  journal_id
) VALUES (
  '5b4932c8-b2d4-4d7b-b1bf-066e160b0ca1',
  '5ae44820-be78-44e1-92c4-449828bb82ad',
  'WITHDRAW',
  10000,
  '2024-03-13 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);