```mermaid
sequenceDiagram
box Trades Journaling System
participant AdminUI
participant UserUI
participant TradeService
participant JournalDB
participant MetricsEngine
end

%% Admin Flow
AdminUI->>TradeService: Manage Asset Types (Instruments, Users)
TradeService->>JournalDB: CRUD Operations
JournalDB-->>TradeService: Confirmation
TradeService-->>AdminUI: Status Update

%% User Core Flow
UserUI->>TradeService: Record Deposit/Withdrawal
TradeService->>JournalDB: Store Transaction
JournalDB->>MetricsEngine: Trigger Recalculation
MetricsEngine->>JournalDB: Update Capital Deployed
JournalDB-->>UserUI: Balance Update

UserUI->>TradeService: Create Trade Entry
TradeService->>JournalDB: Persist Trade
JournalDB->>MetricsEngine: Trigger Position Metrics Calculation
MetricsEngine->>JournalDB: Update all metrics (Exposure etc)
JournalDB-->>UserUI: Trade Confirmation

%% Trade Exit Flow
UserUI->>TradeService: Create Exit Trade
TradeService->>JournalDB: Store Exit
JournalDB->>MetricsEngine: Trigger Metrics Recalculation
MetricsEngine->>JournalDB: Update Position Metrics
JournalDB-->>UserUI: Position Update

%% Updated Note Handling Flow
UserUI->>TradeService: Submit Action (Deposit/Withdraw/Trade Entry/Exit) with Notes
TradeService->>JournalDB: Store Action with Notes
JournalDB->>MetricsEngine: Trigger Recalculation of Related Metrics
MetricsEngine ->> JournalDB: Update related Metrics
JournalDB-->>TradeService: Storage Confirmation
TradeService-->>UserUI: Action Confirmation with Notes

%% Analytics Flow Eg
UserUI->>TradeService: View Analytics (Dashboard, Summary, Positions, All Trades)
TradeService->>JournalDB: Get Position Metrics
JournalDB-->>TradeService: Metrics Data (Exposure, Open Risk etc)
TradeService-->>UserUI: Display Dashboard

```