```mermaid
sequenceDiagram
    participant User
    participant System
    User->>System: Create Entry Trade (100 shares @ 50)
    System->>DB: Insert trades (qty=100)
    User->>System: Exit 50 shares @ 60
    System->>DB: Insert trade_exits (qty_exited=50)
    User->>System: Exit 30 shares @ 55
    System->>DB: Insert trade_exits (qty_exited=30)
    User->>System: View Position → 20 shares remaining
    ```