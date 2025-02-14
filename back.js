const fs = require('fs');
const path = require('path');

// Configuration
const inputFile = path.join(__dirname, 'backup.json');
const outputFile = path.join(__dirname, 'migration.sql');

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
    const { orders, funds, notes } = data.data;
    
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
    
    // 1. Insert Journal
    inserts.push(`
INSERT INTO journals (id, user_id, name, country_id, created_at, updated_at)
VALUES (
  ${escape(journal.id)},
  ${escape(journal.userId)},
  ${escape(journal.name)},
  ${escape(journal.countryId)},
  ${toSqlDate(journal.createdAt)},
  ${toSqlDate(journal.updatedAt)}
);`);

    // 2. Insert Trade Entries (Orders)
    orders.forEach(order => {
      inserts.push(`
INSERT INTO trade_entries (
  id, journal_id, instrument_id, user_id, direction, 
  entry_price, quantity, stop_loss, charges, 
  entry_date, created_at, updated_at
) VALUES (
  ${escape(order.id)},
  ${escape(order.journalId)},
  ${escape(order.instrumentId)},
  ${escape(order.userId)},
  ${order.type === 'BUY' ? "'LONG'" : "'SHORT'"},
  ${sqlValue(order.price, true)},
  ${sqlValue(order.quantity, true)},
  ${sqlValue(order.stoploss, true)},
  ${sqlValue(order.charges, true)},
  ${toSqlDate(order.date)},
  ${toSqlDate(order.createdAt)},
  ${toSqlDate(order.updatedAt)}
);`);

      // 3. Insert Trade Exits (Close Orders)
      order.closeOrders.forEach(closeOrder => {
        inserts.push(`
INSERT INTO trade_exits (
  id, entry_id, journal_id, exit_price, quantity_exited, 
  charges, exit_date, created_at, updated_at
) VALUES (
  ${escape(closeOrder.id)},
  ${escape(order.id)},
  ${escape(order.journalId)},
  ${sqlValue(closeOrder.price, true)},
  ${sqlValue(closeOrder.quantity, true)},
  ${sqlValue(closeOrder.charges, true)},
  ${toSqlDate(closeOrder.date)},
  ${toSqlDate(closeOrder.createdAt)},
  ${toSqlDate(closeOrder.updatedAt)}
);`);
      });
    });

    // 4. Insert Notes (Trade, Journal, and Exit notes)
    const allNotes = [
      ...notes,
      ...orders.flatMap(o => o.notes),
      ...orders.flatMap(o => o.closeOrders.flatMap(co => co.notes))
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
  id, user_id, journal_id, noteable_type, noteable_id, 
  content, chart_url, created_at, updated_at
) VALUES (
  ${escape(note.id)},
  ${escape(note.userId)},
  ${escape(note.journalId || journal.id)},
  '${noteableType}',
  ${escape(noteableId)},
  ${sqlValue(note.content)},
  ${sqlValue(note.chartUrl)},
  ${toSqlDate(note.createdAt)},
  ${toSqlDate(note.updatedAt)}
);`);
    });

    // 5. Insert Funds
    funds.forEach(fund => {
      inserts.push(`
INSERT INTO funds (
  id, user_id, journal_id, type, amount, 
  transaction_date, created_at, updated_at
) VALUES (
  ${escape(fund.id)},
  ${escape(fund.userId)},
  ${escape(fund.journalId)},
  '${fund.type === 'WITHDRAW' ? 'WITHDRAW' : 'DEPOSIT'}',
  ${sqlValue(Math.abs(fund.amount), true)},
  ${toSqlDate(fund.date)},
  ${toSqlDate(fund.createdAt)},
  ${toSqlDate(fund.updatedAt)}
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
