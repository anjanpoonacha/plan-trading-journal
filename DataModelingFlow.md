# Context

This is a software application called **Trading Journal**, used for viewing and logging entered and exited trades while maintaining capital.

# Persona Details

1. **Admin** - Responsible for journal configuration and user management (subscriptions).
2. **User** - Journal creator, manages their own journal.

# Flow of Each Persona - Process Steps

## 1. Admin
- Creates/Manages the Instruments.
- Manages user subscriptions.
- Adjusts app settings as needed.

## 2. User
- Adds funds to the journal via **DEPOSIT** action.
- Creates multiple entry trades.
- Can create multiple exit trades for an entry trade.
- Withdraws funds via **WITHDRAW**.
- Adds notes for all the above actions.
- Should be able to see a dashboard that includes the current trade situation:
    1. **Position Metrics**
        - Open Trades
        - Total Exposure
        - Total Exposure %
        - Total Open Risk
        - Total Open Risk %
    2. **Overview**
        - Capital Deployed
        - Starting Account
        - Account Value

---
---
Future Scope
- If not too complex

	3. **Chart of the Returns Growth**
	4. **R Distribution**
		- Negative -> loss of N * times Risk
		- Positive -> profit of N * Risk

**Note:**
1. Risk = `Quantity * (entry_price - stoploss)` -> LONG
2. Risk = `Quantity * -(entry_price - stoploss)` -> SHORT

[Dashboard Metrics](metricsExplained/DashboardMetrics.md) document outlines the definitions and formulas for key metrics.

- From the dashboard, users can navigate to the **Positions** page.

- User views the `Positions` page which has the following metrics:
    1. Date
    2. Type (LONG | SHORT)
    3. Open Quantity
    4. Open %
    5. Entry Price
    6. SL 
    7. SL %
    8. Current SL
    9. Exposure
    10. Exposure %
    11. Total Exposure
    12. Total Exposure %
    13. Open Risk
    14. Open Risk %
    15. Total Open Risk (TOR)
    16. Total Open Risk %
    17. CMP (Current Market Price) - (needs external API call)
    18. Net Profit (Should include the charges also)

    For more details, refer to the [Position Metrics](metricsExplained/2.PositionMetrics.md).

- User views the `Order History` page which has the latest orders at the top:
    1. Symbol
    2. Date
    3. Type
    4. Quantity
    5. Entry
    6. SL
    7. SL %
    8. Position Size
    9. Position Size %
    10. RPT
    11. RPT %
    12. Exit %
    13. Exit Price
    14. Latest Exit Date
    15. Gain %
    16. Capital Deployed
    17. RoCD
    18. Starting Account
    19. RoSV
    20. Account Value
    21. Account Gain %
    22. Days
    23. RR
    24. Charges
    25. Net Profit (Should include the charges also)
    26. Actions

- User can activate the following actions:
    - Open Detail page
    - Edit the Entry Order
    - Delete the Entry Order

- User opens the `Order Detail Page`:
    - Sees the Instrument (stock, crypto) details, Gain, Gain%, RR at the header.
    - Avg. Entry Price, Avg. Exit Price, Account Value, Position Size (and %), Stoploss (and %), RPT (and %).
    - Table with the following details:
        - Type
        - Date
        - Days
        - Price
        - Qty
        - Charges
        - Profit
        - R Multiple
        - Actions

    The table must have the exit records and above metrics for each record, along with overall totals in the last row.
    - User can activate the following actions:
        - Delete Entry / Exit record
        - Edit the Entry / Exit record

- User opens the `Funds` section:
    - Can `DEPOSIT` X amount.
    - Can `WITHDRAW` X amount.
    - Can undo any of the above actions




