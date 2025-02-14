
INSERT INTO users (id, email, created_at)
VALUES (
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'placeholder@example.com',
  NOW()
);


INSERT INTO journals (id, user_id, name, created_at)
VALUES (
  'cd03b578-8769-47db-a51d-be9be4584bac',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'India',
  '2024-02-15 05:34:11'
);


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'c707f718-6be8-486d-ae33-db5d63167031',
  'SYM-c707f718',
  'Instrument c707f718',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '5086e20a-8c41-4ae3-9682-8f957b7c3a4d',
  'SYM-5086e20a',
  'Instrument 5086e20a',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '9a6f3bbc-8fff-417f-9372-69580ae21806',
  'SYM-9a6f3bbc',
  'Instrument 9a6f3bbc',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'bcf13888-f232-4356-8c99-a727db74b32a',
  'SYM-bcf13888',
  'Instrument bcf13888',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'ad91fc9d-db5d-46c9-b90c-2da0082ef26e',
  'SYM-ad91fc9d',
  'Instrument ad91fc9d',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '2be5eaaf-70d7-4f03-8a43-d4537a689818',
  'SYM-2be5eaaf',
  'Instrument 2be5eaaf',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '2379d3ea-770c-4549-b832-1a556cd9e809',
  'SYM-2379d3ea',
  'Instrument 2379d3ea',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '64078379-092a-4c3c-8758-c9958b43a650',
  'SYM-64078379',
  'Instrument 64078379',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'eaa1dd07-3f83-42d7-8251-892a4067b140',
  'SYM-eaa1dd07',
  'Instrument eaa1dd07',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '2330f3fb-6153-4d56-be7e-77932a5682a0',
  'SYM-2330f3fb',
  'Instrument 2330f3fb',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '412ae5d5-c047-41e7-ab2c-7b0a73dc1b96',
  'SYM-412ae5d5',
  'Instrument 412ae5d5',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '4243d6a9-32b8-46b6-87e3-c3dd6e88c7e2',
  'SYM-4243d6a9',
  'Instrument 4243d6a9',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '3330d5cc-a162-4d86-a5d1-e08d171255c1',
  'SYM-3330d5cc',
  'Instrument 3330d5cc',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '1f37b810-bc35-4fa1-8712-4f3dbea5ad0f',
  'SYM-1f37b810',
  'Instrument 1f37b810',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '49a6149f-7b36-42d3-a589-30e6095307de',
  'SYM-49a6149f',
  'Instrument 49a6149f',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '57e12661-49e3-4611-bb6a-b988d48aaea2',
  'SYM-57e12661',
  'Instrument 57e12661',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'c21dfaf8-fd0c-44ff-a2e0-e7bb9beaa903',
  'SYM-c21dfaf8',
  'Instrument c21dfaf8',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'b48e4d34-7869-4ea0-a204-3562ddcb408a',
  'SYM-b48e4d34',
  'Instrument b48e4d34',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '2bd3e437-2e43-43ae-be65-b70851a30fcf',
  'SYM-2bd3e437',
  'Instrument 2bd3e437',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '87392321-e7a0-4eee-99a5-a364a2ae99c6',
  'SYM-87392321',
  'Instrument 87392321',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'a0b9811e-19c2-477e-9b20-4ebe484d503f',
  'SYM-a0b9811e',
  'Instrument a0b9811e',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'cbc314ad-ad77-4a78-879f-17f98ae6c687',
  'SYM-cbc314ad',
  'Instrument cbc314ad',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '07e9faeb-469d-4e30-bc7e-6b5a6c55d87f',
  'SYM-07e9faeb',
  'Instrument 07e9faeb',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'a2a5097b-4929-4153-8124-c4770939d2bc',
  'SYM-a2a5097b',
  'Instrument a2a5097b',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '7114c22e-4fa7-4bab-8f09-5e6e8d6e9fff',
  'SYM-7114c22e',
  'Instrument 7114c22e',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'e261650f-7e15-441c-9f79-daef4aa42cf9',
  'SYM-e261650f',
  'Instrument e261650f',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'f320bc91-88e6-450f-a1ef-26019aa43f4e',
  'SYM-f320bc91',
  'Instrument f320bc91',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '2531664c-6dc3-40fc-ac14-621909a367ca',
  'SYM-2531664c',
  'Instrument 2531664c',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '2edcf821-6c95-465c-8925-d612a9419c16',
  'SYM-2edcf821',
  'Instrument 2edcf821',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  'e6215d70-0a4f-477d-8e65-bda98b84c860',
  'SYM-e6215d70',
  'Instrument e6215d70',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO instruments (id, symbol, name, type)
VALUES (
  '0c62cb2f-ea6c-480f-b2b1-8db08b62932f',
  'SYM-0c62cb2f',
  'Instrument 0c62cb2f',
  'stock'
) ON CONFLICT (id) DO NOTHING;


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '378d5307-2a4d-4d5f-94dd-2dc32e357c8b',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'c707f718-6be8-486d-ae33-db5d63167031',
  'LONG',
  4,
  395,
  382,
  '2024-03-28 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '9724d6d1-7e51-4228-a999-32fdeec579a6',
  '378d5307-2a4d-4d5f-94dd-2dc32e357c8b',
  '2024-04-10 00:00:00',
  431,
  4,
  18,
  395,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '434de719-935b-4a05-bf1b-bdf427f9f40d',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '5086e20a-8c41-4ae3-9682-8f957b7c3a4d',
  'LONG',
  100,
  494.7,
  477,
  '2024-04-10 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '40a76f5f-17e8-4ebb-ae5f-3826203da45a',
  '434de719-935b-4a05-bf1b-bdf427f9f40d',
  '2024-04-20 00:00:00',
  477,
  100,
  65.82,
  494.7,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  'd45d4bee-0b0a-4c6a-a1e2-fbba8415d0bf',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '5086e20a-8c41-4ae3-9682-8f957b7c3a4d',
  'LONG',
  83,
  495,
  477,
  '2024-04-10 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '017fae87-40d7-4339-8954-48f39774e853',
  'd45d4bee-0b0a-4c6a-a1e2-fbba8415d0bf',
  '2024-04-18 00:00:00',
  477,
  83,
  57.5,
  495,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '6bf75d73-2ef2-428d-9a82-ca630ac4fc0c',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '9a6f3bbc-8fff-417f-9372-69580ae21806',
  'LONG',
  750,
  1465,
  1450,
  '2024-04-18 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'ec2dfe9f-8aa5-4463-abea-2a062e0e5347',
  '6bf75d73-2ef2-428d-9a82-ca630ac4fc0c',
  '2024-04-20 00:00:00',
  1440,
  750,
  1138.62,
  1465,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '3fd25d73-6e28-4338-8240-6973ab907ad8',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'bcf13888-f232-4356-8c99-a727db74b32a',
  'LONG',
  2208,
  1103,
  1090,
  '2024-04-19 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'f0af90a5-6faa-4ddd-bd25-097ea6999bd4',
  '3fd25d73-6e28-4338-8240-6973ab907ad8',
  '2024-04-19 00:00:00',
  1090,
  2208,
  2518.07,
  1103,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  'cafa167c-5430-4036-bbbe-c907643470f4',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '9a6f3bbc-8fff-417f-9372-69580ae21806',
  'LONG',
  2208,
  1465,
  1440,
  '2024-04-19 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'cea4ed59-dba0-4630-8b17-1f20bc701ff4',
  'cafa167c-5430-4036-bbbe-c907643470f4',
  '2024-04-22 00:00:00',
  1450,
  1104,
  1680.21,
  1465,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'c211f3af-019d-4c7b-a9c3-c1f3e470c65f',
  'cafa167c-5430-4036-bbbe-c907643470f4',
  '2024-04-22 00:00:00',
  1450,
  1104,
  1696.86,
  1465,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '4b7e7cca-a78d-41ab-a142-7f49bdf6b06b',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'bcf13888-f232-4356-8c99-a727db74b32a',
  'LONG',
  25,
  1114,
  1072,
  '2024-04-22 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'ac032067-0741-4a86-8c81-6d4a78e697c3',
  '4b7e7cca-a78d-41ab-a142-7f49bdf6b06b',
  '2024-04-29 00:00:00',
  1123,
  25,
  40.51,
  1114,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '8c53c2c3-6944-446b-bd46-26770f130d65',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'ad91fc9d-db5d-46c9-b90c-2da0082ef26e',
  'LONG',
  255,
  435.6,
  420.85,
  '2024-04-23 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '66d26493-c8c1-48a4-9079-4820653818d0',
  '8c53c2c3-6944-446b-bd46-26770f130d65',
  '2024-04-29 00:00:00',
  450.81,
  255,
  135.47,
  435.6,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '213f0f7a-3083-491e-b4f9-1619cb39df1d',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '2be5eaaf-70d7-4f03-8a43-d4537a689818',
  'LONG',
  90,
  858,
  822.25,
  '2024-04-23 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '7e024043-9453-4708-8dc2-00009f32d095',
  '213f0f7a-3083-491e-b4f9-1619cb39df1d',
  '2024-04-29 00:00:00',
  907,
  18,
  101.15,
  858,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '0d03a7ba-6cdf-48c8-b42f-27fc7619524f',
  '213f0f7a-3083-491e-b4f9-1619cb39df1d',
  '2024-05-17 00:00:00',
  870,
  72,
  81.41,
  858,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '3f7445a2-4d6d-4bcf-93fd-fe1db5c39bee',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '2379d3ea-770c-4549-b832-1a556cd9e809',
  'LONG',
  225,
  172.5,
  165.8,
  '2024-04-26 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '6cbc9467-0fb6-44b9-9964-e001c65ea2c3',
  '3f7445a2-4d6d-4bcf-93fd-fe1db5c39bee',
  '2024-04-30 00:00:00',
  165.8,
  225,
  54.4,
  172.5,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '89741f20-efcc-411b-86e4-8ce04edbc1ff',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '64078379-092a-4c3c-8758-c9958b43a650',
  'LONG',
  170,
  575,
  558,
  '2024-04-30 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '6a0ab5ff-f9a2-4c0c-9dde-edef4c071576',
  '89741f20-efcc-411b-86e4-8ce04edbc1ff',
  '2024-05-17 00:00:00',
  555,
  170,
  113.66,
  575,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '872951b8-15ee-48e4-811a-554506727730',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'eaa1dd07-3f83-42d7-8251-892a4067b140',
  'LONG',
  87,
  1051,
  998,
  '2024-04-30 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '0d838490-682b-445e-98c2-0f4391ea9f64',
  '872951b8-15ee-48e4-811a-554506727730',
  '2024-04-30 00:00:00',
  1022,
  87,
  108.45,
  1051,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '94ff82c5-ad8e-4351-924e-30a9a173724d',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '2330f3fb-6153-4d56-be7e-77932a5682a0',
  'LONG',
  300,
  340.8,
  329.2,
  '2024-05-17 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '39ac2265-86d6-4895-ad44-336fea5c066f',
  '94ff82c5-ad8e-4351-924e-30a9a173724d',
  '2024-05-23 00:00:00',
  359,
  300,
  128.19,
  340.8,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '6ed661b8-94c1-40d2-be2b-458e15ce1911',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '412ae5d5-c047-41e7-ab2c-7b0a73dc1b96',
  'LONG',
  2100,
  457.4,
  450,
  '2024-05-15 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '637554d4-7197-4004-89ea-fefb5884ede6',
  '6ed661b8-94c1-40d2-be2b-458e15ce1911',
  '2024-05-17 00:00:00',
  473,
  2100,
  171.03,
  457.4,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '3947bebb-23d0-4ac5-a601-6275f75b4dce',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '4243d6a9-32b8-46b6-87e3-c3dd6e88c7e2',
  'LONG',
  2000,
  33.05,
  31.35,
  '2024-05-17 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'cbe7da1f-688e-42d8-b8c9-8b809499f529',
  '3947bebb-23d0-4ac5-a601-6275f75b4dce',
  '2024-06-04 00:00:00',
  31,
  2000,
  80.37,
  33.05,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '891e12cd-302b-4a99-8da6-238ceba21128',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '3330d5cc-a162-4d86-a5d1-e08d171255c1',
  'LONG',
  300,
  407.4,
  398,
  '2024-05-17 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '6a6f5edd-8a41-4669-9a84-86451abf8d33',
  '891e12cd-302b-4a99-8da6-238ceba21128',
  '2024-05-23 00:00:00',
  407.2,
  300,
  142.76,
  407.4,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '13153818-f8be-4a9a-9e8e-11dcd56624e1',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '1f37b810-bc35-4fa1-8712-4f3dbea5ad0f',
  'LONG',
  794,
  171,
  164,
  '2024-05-17 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'dad91bff-e4c0-4693-8463-b5e0a8d80327',
  '13153818-f8be-4a9a-9e8e-11dcd56624e1',
  '2024-05-25 00:00:00',
  183,
  100,
  34.65,
  171,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '6b6830e3-006b-4c25-bf48-b8eb963d408a',
  '13153818-f8be-4a9a-9e8e-11dcd56624e1',
  '2024-05-25 00:00:00',
  191,
  100,
  0,
  171,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '4843d6a4-5913-4dd5-bec1-d066051dbc5d',
  '13153818-f8be-4a9a-9e8e-11dcd56624e1',
  '2024-05-25 00:00:00',
  191,
  100,
  35.69,
  171,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '9e8348f8-5030-4467-a0f4-e96bebd3f0f7',
  '13153818-f8be-4a9a-9e8e-11dcd56624e1',
  '2024-05-23 00:00:00',
  189.45,
  494,
  113.62,
  171,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  'c1b94124-b585-4f4c-aa5c-ba78156b7831',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '49a6149f-7b36-42d3-a589-30e6095307de',
  'LONG',
  89,
  811,
  780,
  '2024-05-10 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'f45d5106-a381-430b-aa0f-97df23a30bee',
  'c1b94124-b585-4f4c-aa5c-ba78156b7831',
  '2024-05-21 00:00:00',
  836,
  89,
  92.87,
  811,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '47cf11e2-c6b0-42aa-ad35-91a14c47bc0c',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '57e12661-49e3-4611-bb6a-b988d48aaea2',
  'LONG',
  200,
  205.24,
  197.3,
  '2024-05-18 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'bd59f77e-7030-46d0-a7d2-aa1f3a7103ce',
  '47cf11e2-c6b0-42aa-ad35-91a14c47bc0c',
  '2024-05-25 00:00:00',
  223.75,
  40,
  25.28,
  205.24,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'fc7d9bf1-4d76-4860-809e-b66c25cbfbf5',
  '47cf11e2-c6b0-42aa-ad35-91a14c47bc0c',
  '2024-05-23 00:00:00',
  225,
  160,
  53.36,
  205.24,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '4f3e9167-54ec-45fd-a63f-7eaa522d9db2',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'c21dfaf8-fd0c-44ff-a2e0-e7bb9beaa903',
  'LONG',
  100,
  328,
  315,
  '2024-05-18 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'bdac130b-1b21-4871-a3ca-4d3368e37bc4',
  '4f3e9167-54ec-45fd-a63f-7eaa522d9db2',
  '2024-05-25 00:00:00',
  377,
  100,
  55.43,
  328,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '5aeb0978-5c2f-4daa-848a-5eebb2b2dc50',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'b48e4d34-7869-4ea0-a204-3562ddcb408a',
  'LONG',
  650,
  245.25,
  237,
  '2024-05-23 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'e95a4fb6-e38e-4441-ba54-abfe99c0651f',
  '5aeb0978-5c2f-4daa-848a-5eebb2b2dc50',
  '2024-05-28 00:00:00',
  235.25,
  650,
  174.97,
  245.25,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '435fab19-1c65-4ed1-848b-2df2cf308a32',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '2bd3e437-2e43-43ae-be65-b70851a30fcf',
  'LONG',
  150,
  3810.85,
  3785,
  '2024-05-28 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '6b8840b5-09e1-498e-9aeb-28306a716101',
  '435fab19-1c65-4ed1-848b-2df2cf308a32',
  '2024-05-28 00:00:00',
  3916.75,
  150,
  86.86,
  3810.85,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '929a648b-e4f4-4ad1-9d57-e0451ed5b549',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '87392321-e7a0-4eee-99a5-a364a2ae99c6',
  'LONG',
  276,
  372.5,
  361,
  '2024-05-18 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '51d1f067-94d7-4bbf-81b8-9c36adc66116',
  '929a648b-e4f4-4ad1-9d57-e0451ed5b549',
  '2024-05-28 00:00:00',
  361,
  276,
  119.87,
  372.5,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  'e30aae1a-cb26-4834-9b0f-2afe0c363316',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'a0b9811e-19c2-477e-9b20-4ebe484d503f',
  'LONG',
  20,
  2230,
  2200,
  '2024-05-14 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '6bbcdd25-547c-44c9-9cf2-51884aba750b',
  'e30aae1a-cb26-4834-9b0f-2afe0c363316',
  '2024-05-23 00:00:00',
  2334,
  20,
  64.78,
  2230,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '8ef09836-2dc7-46d7-96a5-78987df501b1',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'cbc314ad-ad77-4a78-879f-17f98ae6c687',
  'LONG',
  1700,
  66.1,
  62,
  '2024-05-25 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '6f4f9940-822b-4d43-b007-b784c750a15d',
  '8ef09836-2dc7-46d7-96a5-78987df501b1',
  '2024-05-28 00:00:00',
  68,
  1700,
  136.51,
  66.1,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '3a9095ef-8924-4996-a9bd-a02544f900b3',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '07e9faeb-469d-4e30-bc7e-6b5a6c55d87f',
  'LONG',
  14,
  689,
  657,
  '2024-08-16 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '46c2befe-a45f-4753-a6c5-e18fd2c0bda7',
  '3a9095ef-8924-4996-a9bd-a02544f900b3',
  '2024-08-23 00:00:00',
  771.4,
  3,
  18.02,
  689,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'cbdeeb3a-9f99-4028-b2f0-4a0e82f56d59',
  '3a9095ef-8924-4996-a9bd-a02544f900b3',
  '2024-12-01 00:00:00',
  689,
  11,
  0,
  689,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  'db3ebb8c-c266-4875-9492-a57c95eec013',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'a2a5097b-4929-4153-8124-c4770939d2bc',
  'LONG',
  186,
  59.8,
  57.65,
  '2024-08-22 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '16f2010d-5ce1-4df1-b6e7-563dc7f205a1',
  'db3ebb8c-c266-4875-9492-a57c95eec013',
  '2024-08-23 00:00:00',
  67.8,
  60,
  20.08,
  59.8,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '55d593f5-8dd4-4721-bbd4-986a04e8133c',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '7114c22e-4fa7-4bab-8f09-5e6e8d6e9fff',
  'LONG',
  47,
  264.7,
  256,
  '2024-08-20 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '9d84a00f-c18d-4b68-9461-a7cac17ee406',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'e261650f-7e15-441c-9f79-daef4aa42cf9',
  'LONG',
  49,
  216.1,
  208,
  '2024-08-22 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'da8ac4c9-70ff-4b3a-b7da-abfd4242cf03',
  '9d84a00f-c18d-4b68-9461-a7cac17ee406',
  '2024-08-23 00:00:00',
  238.3,
  10,
  18.02,
  216.1,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '87561c12-eff5-4666-ab64-04a6f31c0497',
  '9d84a00f-c18d-4b68-9461-a7cac17ee406',
  '2024-12-01 00:00:00',
  216.1,
  39,
  24.26,
  216.1,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '5b2a4b59-c1fa-4f67-a8b3-ed0fdff4d3fa',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'f320bc91-88e6-450f-a1ef-26019aa43f4e',
  'LONG',
  119,
  87,
  83,
  '2024-08-21 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'efef4540-9fd4-4c50-ac4f-de730bd831f0',
  '5b2a4b59-c1fa-4f67-a8b3-ed0fdff4d3fa',
  '2024-08-28 00:00:00',
  97.85,
  30,
  19.05,
  87,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  '38635ed2-afae-4a91-bc32-8cdf74a61c87',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '2531664c-6dc3-40fc-ac14-621909a367ca',
  'LONG',
  117,
  96.95,
  93.5,
  '2024-08-19 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '6d824d3e-17da-40bf-bf5d-d30a2c9417b4',
  '38635ed2-afae-4a91-bc32-8cdf74a61c87',
  '2025-02-10 00:00:00',
  96.95,
  10,
  16.97,
  96.95,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '70d05f55-1d95-4689-b264-d98ec331964d',
  '38635ed2-afae-4a91-bc32-8cdf74a61c87',
  '2025-02-10 00:00:00',
  96.95,
  10,
  0,
  96.95,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  'a8200d5e-063f-41cc-be3b-1d37c01eb400',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '2edcf821-6c95-465c-8925-d612a9419c16',
  'LONG',
  84,
  342,
  330,
  '2024-08-27 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'ec03b040-63fe-4d4b-b780-72565276d3c3',
  'a8200d5e-063f-41cc-be3b-1d37c01eb400',
  '2024-12-01 00:00:00',
  342,
  20,
  46.06,
  342,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'd39e8a28-ee5c-4994-a14a-768977798c04',
  'a8200d5e-063f-41cc-be3b-1d37c01eb400',
  '2025-02-11 00:00:00',
  342,
  64,
  0,
  342,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  'd9642bfd-e303-4b8d-b7e3-2867528e93c0',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '2531664c-6dc3-40fc-ac14-621909a367ca',
  'LONG',
  1,
  180,
  170,
  '2024-12-21 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '7c28a80f-824a-4de8-b3f7-8bf7a952b362',
  'd9642bfd-e303-4b8d-b7e3-2867528e93c0',
  '2025-02-10 00:00:00',
  200,
  1,
  15.94,
  180,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  'e3b7e1a6-d403-45cc-ada7-896456615e19',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'e6215d70-0a4f-477d-8e65-bda98b84c860',
  'LONG',
  10,
  150,
  140,
  '2025-02-11 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  '4cee6e68-cb74-4e34-beb8-91ebfbf1d2e2',
  'e3b7e1a6-d403-45cc-ada7-896456615e19',
  '2025-02-11 00:00:00',
  200,
  4,
  0,
  150,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  'bb0ff188-9bfd-4fa4-ad51-605cfdbcb4c0',
  'e3b7e1a6-d403-45cc-ada7-896456615e19',
  '2025-02-11 00:00:00',
  130,
  4,
  16.95,
  150,
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id
) VALUES (
  'f007c0ff-5ba7-4a05-b3e2-f2d959dc7ed4',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  '0c62cb2f-ea6c-480f-b2b1-8db08b62932f',
  'LONG',
  100,
  100,
  90,
  '2025-02-12 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO funds (
  id, user_id, type, amount, transaction_date, 
  journal_id
) VALUES (
  'ace6d6bb-9e67-42ed-9aaf-c09b76af5050',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'DEPOSIT',
  20000,
  '2024-03-14 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO funds (
  id, user_id, type, amount, transaction_date, 
  journal_id
) VALUES (
  '1a907af4-b255-4f2d-bea1-94a2080a5de0',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'DEPOSIT',
  800000,
  '2024-04-10 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO funds (
  id, user_id, type, amount, transaction_date, 
  journal_id
) VALUES (
  'ab8ad124-229e-4bcf-804f-86eb9f398881',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'DEPOSIT',
  200000,
  '2024-04-10 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);


INSERT INTO funds (
  id, user_id, type, amount, transaction_date, 
  journal_id
) VALUES (
  '1c60aec7-f9e0-4979-9ba0-da939ebfd77b',
  '8D9B81B5-A028-4643-8CEF-645495AFAD55',
  'WITHDRAW',
  790172,
  '2024-08-16 00:00:00',
  'cd03b578-8769-47db-a51d-be9be4584bac'
);