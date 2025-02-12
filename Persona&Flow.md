

## Enhanced Persona Definitions
### 1. Admin Persona 
- **Core Responsibilities**:
  - Instrument lifecycle management (CRUD operations)
  - System configuration (if any)
  

### 2. User Persona 
- **Enhanced Trading Flow**:
  - Trade simulation with "what-if" analysis (paper trading)
  - Risk validation before trade execution
  - Multi-legged exit strategies


# Persona Flows Explained

## Admin Flow

### 1. Instrument Management Cycle
1. **Create New Instruments**  
   - Add financial assets (stocks, crypto pairs, forex) to the system catalog  
   - Define trading parameters and metadata fields  
   - Set default risk calculation rules per asset class  

2. **Maintain Existing Instruments**  
   - Update symbol details and trading parameters  
   - Modify asset classification (e.g., sector for stocks)  
   - Archive deprecated/inactive instruments  

3. **Validation & Publishing**  
   - Verify instrument configuration  
   - Push changes to production environment  
   - Monitor integration with price feeds  

### 2. Subscription Management


2. **User Management**  
   - subscription plans (active)  

## User Flow

### 1. Capital Management Process
1. **Deposit Funds**  
   - Record deposit amount and date  
   - Add optional note about fund source  
   - Verify updated capital deployed metric  

2. **Withdraw Funds**  
   - Request withdrawal with amount and date  
   - Add withdrawal reason note  
   - Confirm sufficient available balance  

3. **Capital Tracking**  
   - View net capital deployed over time  
   - Filter transactions by date/type  
   - Export capital changes history  

### 2. Trade Journaling Workflow
1. **Trade Entry**  
   a. Select instrument from available list  
   b. Record entry price, quantity, and direction (Long/Short)  
   c. Set initial stop loss level  
   d. Add trade rationale notes  
   e. Confirm position metrics calculation  

2. **Trade Exit**  
   a. Select entry to close (fully/partially)  
   b. Record exit price and quantity  
   c. Add exit reason notes  
   d. View updated realized P&L  
   e. Verify remaining position (if partial exit)  

3. **Trade Adjustments**  
   - Modify stop loss levels  
   - Add incremental notes to existing trades  
   - Split positions into multiple exits  

### 3. Analysis & Reporting
1. **Dashboard Monitoring**  
   - View real-time position metrics:  
     - Total Exposure (Σ Entry Price × Quantity)  
     - Open Risk (Σ (SL - Entry) × Quantity)  
   - Track account health indicators:  
     - Capital Deployed vs. Account Value  
     - Risk/Exposure percentages  

2. **Historical Analysis**  
   - Filter trades by date/instrument/result  
   - Compare actual vs. expected performance  
   - Generate custom period reports  

3. **Verification Process**  
   - Cross-check dashboard metrics with trade records  
   - Export data for external validation  
   - Recalculate key metrics using raw trade data  

