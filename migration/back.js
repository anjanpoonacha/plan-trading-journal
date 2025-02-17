const fs = require('fs');
const path = require('path');


const file = 'backup_with_minimal.json';
// Configuration
const inputFile = path.join(__dirname, file);
const outputFile = path.join(__dirname, `migration_${file}.sql`);

// Add this constant at the top of the file
const USER_ID = '5ae44820-be78-44e1-92c4-449828bb82ad';

// Helper functions
const toSqlDate = (isoString) => isoString ? `'${isoString.split('.')[0].replace('T', ' ')}'` : 'NOW()';

// Add this custom escape function
const escape = (value) => {
  if (value === null || value === undefined) return 'NULL';
  if (typeof value === 'number') return value;
  return `'${value.toString().replace(/'/g, "''")}'`;
};

// Update the sqlValue function to use our custom escape
const sqlValue = (val, isNumber = false) => {
  if (val === null || val === undefined) return 'NULL';
  return isNumber ? val : escape(val);
};

// Main conversion function
async function convertJsonToSql() {
  try {
    const data = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
    
    // Add validation for required data
    if (!data || !data.data) {
      throw new Error('Invalid JSON structure: missing data property');
    }
    
    // Extract journal and other data from the nested structure
	  const journal = data.data;
	  journal.userId = USER_ID;
    const { orders, funds, notes, instruments: rawInstruments } = data.data;
    
    // Validate journal exists
    if (!journal || !journal.id) {
      throw new Error('Invalid JSON structure: journal data is missing or incomplete');
    }
    
    // Validate other required arrays exist
    if (!Array.isArray(orders)) {
      throw new Error('Invalid JSON structure: orders must be an array');
    }
    if (!Array.isArray(funds)) {
      throw new Error('Invalid JSON structure: funds must be an array');
    }
    if (!Array.isArray(notes)) {
      throw new Error('Invalid JSON structure: notes must be an array');
    }

    const inserts = [];
    
    // 1. Insert Users
    inserts.push(`
INSERT INTO users (id, email, created_at)
VALUES (
  '${USER_ID}',
  'placeholder@example.com',
  NOW()
);`);

    // 2. Insert Journal
    inserts.push(`
INSERT INTO journals (id, user_id, name, created_at)
VALUES (
  ${escape(journal.id)},
  '${USER_ID}',
  ${escape(journal.name)},
  ${toSqlDate(journal.createdAt)}
);`);

    // Add instrument processing before trade entries
    const instruments = new Map();
    orders.forEach(order => {
      if (order.instrumentId && !instruments.has(order.instrumentId)) {
        instruments.set(order.instrumentId, {
          id: order.instrumentId,
          symbol: `SYM-${order.instrumentId.slice(0, 8)}`, // Placeholder
          name: `Instrument ${order.instrumentId.slice(0, 8)}`,
          type: 'stock' // Default type
        });
      }
    });

    // 3. Insert Instruments
    Array.from(instruments.values()).forEach(instrument => {
      inserts.push(`
INSERT INTO instruments (id, symbol, name, type)
VALUES (
  ${escape(instrument.id)},
  ${escape(instrument.symbol)},
  ${escape(instrument.name)},
  ${escape(instrument.type)}
) ON CONFLICT (id) DO NOTHING;`);
    });

    // 4. Insert Trade Entries (Orders)
    orders.forEach(order => {
      inserts.push(`
INSERT INTO trade_entries (
  id, user_id, instrument_id, direction, quantity, 
  entry_price, stop_loss, entry_date, journal_id, charges
) VALUES (
  ${escape(order.id)},
  '${USER_ID}',
  ${escape(order.instrumentId)},
  ${order.type === 'BUY' ? "'LONG'" : "'SHORT'"},
  ${sqlValue(order.quantity, true)},
  ${sqlValue(order.price, true)},
  ${sqlValue(order.stoploss, true)},
  ${toSqlDate(order.date)},
  ${escape(order.journalId)},
  ${sqlValue(order.charges, true)}
);`);

      // 4. Insert Trade Exits (Close Orders)
      order.closeOrders.forEach(closeOrder => {
        inserts.push(`
INSERT INTO trade_exits (
  id, entry_id, exit_date, exit_price, quantity_exited, 
  charges, entry_price, journal_id
) VALUES (
  ${escape(closeOrder.id)},
  ${escape(order.id)},
  ${toSqlDate(closeOrder.date)},
  ${sqlValue(closeOrder.price, true)},
  ${sqlValue(closeOrder.quantity, true)},
  ${sqlValue(closeOrder.charges, true)},
  ${sqlValue(order.price, true)},
  ${escape(order.journalId)}
);`);
      });
    });

    // 5. Insert Notes (Trade, Journal, and Exit notes)
    const allNotes = [
    //   ...notes,
    //   ...orders.flatMap(o => o.notes),
    //   ...orders.flatMap(o => o.closeOrders.flatMap(co => co.notes))
    ];

    allNotes.forEach(note => {
      let noteableType = 'journal';
      let noteableId = journal.id;

      if (note.orderId) {
        noteableType = 'trade_entry';
        noteableId = note.orderId;
      } else if (note.closeOrderId) {
        noteableType = 'trade_exit';
        noteableId = note.closeOrderId;
      }

      inserts.push(`
INSERT INTO notes (
  id, user_id, noteable_type, noteable_id, content, 
  journal_id, created_at
) VALUES (
  ${escape(note.id)},
  '${USER_ID}',
  '${noteableType}',
  ${escape(noteableId)},
  ${sqlValue(note.content)},
  ${escape(note.journalId || journal.id)},
  ${toSqlDate(note.createdAt)}
);`);
    });

    // 6. Insert Funds
    funds.forEach(fund => {
      inserts.push(`
INSERT INTO funds (
  id, user_id, type, amount, transaction_date, 
  journal_id
) VALUES (
  ${escape(fund.id)},
  '${USER_ID}',
  '${fund.type === 'WITHDRAW' ? 'WITHDRAW' : 'DEPOSIT'}',
  ${sqlValue(Math.abs(fund.amount), true)},
  ${toSqlDate(fund.date)},
  ${escape(fund.journalId)}
);`);
    });

    // Write to file
    fs.writeFileSync(outputFile, inserts.join('\n\n'));
    console.log(`Generated SQL file with ${inserts.length} insert statements at ${outputFile}`);
  } catch (error) {
    console.error('Error during conversion:', error.message);
    process.exit(1);
  }
}

// Run the conversion
convertJsonToSql().catch(console.error);
