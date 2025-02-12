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

 [Dashboard Metrics](metricsExplained/DashboardMetrics.md) document outlines the definitions and formulas for key metrics.

---
---
### Future Scope
- If not too complex

	3. **Chart of the Returns Growth**
	4. **R Distribution**
		- Negative -> loss of N * times Risk
		- Positive -> profit of N * Risk


**Note:**
1. Risk = `Quantity * (entry_price - stoploss)` -> LONG
2. Risk = `Quantity * -(entry_price - stoploss)` -> SHORT

- From the dashboard, users can navigate to the **Positions** section.

Users should be able to view a detailed history of all their trades, including entry and exit points, profits/losses, and timestamps.
