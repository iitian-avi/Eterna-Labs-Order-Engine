# Order Execution Engine - System Architecture

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT / API USER                        │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                    HTTP Request (JSON)
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EXPRESS REST API                            │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  POST /api/orders      - Create Order                       │ │
│  │  GET  /api/orders/:id  - Get Order                          │ │
│  │  GET  /api/orders      - Get All Orders                     │ │
│  │  DELETE /api/orders/:id - Cancel Order                      │ │
│  │  GET  /api/orderbook/:symbol - Get Order Book               │ │
│  │  GET  /api/trades      - Get Trades                         │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                    Validation & Routing
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ORDER BOOK MANAGER                            │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  • Validate Order Input                                     │ │
│  │  • Create Order Object                                      │ │
│  │  • Manage Order Lifecycle                                   │ │
│  │  • Aggregate Order Book Data                                │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                    Submit Order for Matching
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      MATCHING ENGINE                             │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  1. Receive Order                                           │ │
│  │  2. Check for Matching Orders                               │ │
│  │  3. Execute Trades (Price-Time Priority)                    │ │
│  │  4. Update Order Status                                     │ │
│  │  5. Add Unfilled Orders to Order Book                       │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │  BUY ORDERS     │  │   SELL ORDERS    │  │    TRADES      │ │
│  │  (Price DESC)   │  │   (Price ASC)    │  │   (History)    │ │
│  │  ┌───────────┐  │  │  ┌───────────┐   │  │  ┌──────────┐ │ │
│  │  │ $151 x100 │  │  │  │ $150 x50  │   │  │  │ Trade 1  │ │ │
│  │  │ $150 x75  │  │  │  │ $151 x100 │   │  │  │ Trade 2  │ │ │
│  │  │ $149 x200 │  │  │  │ $152 x150 │   │  │  │ Trade 3  │ │ │
│  │  └───────────┘  │  │  └───────────┘   │  │  └──────────┘ │ │
│  └─────────────────┘  └──────────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                               │
                    Return: Order + Trades
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                     RESPONSE TO CLIENT                           │
│  {                                                                │
│    "success": true,                                               │
│    "data": {                                                      │
│      "order": { "id": "...", "status": "FILLED", ... },          │
│      "trades": [{ "id": "...", "price": 150, ... }]              │
│    }                                                              │
│  }                                                                │
└─────────────────────────────────────────────────────────────────┘
```

## Matching Algorithm Flow

```
┌──────────────────────┐
│  New Order Arrives   │
│  (BUY $150 x100)     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────────┐
│  Is it a BUY or SELL order?          │
└──────────┬───────────────────────────┘
           │
           ├─── BUY ────────────────────────────┐
           │                                     │
           │                                     ▼
           │                    ┌────────────────────────────────┐
           │                    │ Get SELL orders for symbol     │
           │                    │ (sorted by price ASC)          │
           │                    └────────────┬───────────────────┘
           │                                 │
           │                                 ▼
           │                    ┌────────────────────────────────┐
           │                    │ For each SELL order:           │
           │                    │   If BUY price >= SELL price   │
           │                    │     → Execute Trade            │
           │                    │     → Update filled quantities │
           │                    │   Else: Stop matching          │
           │                    └────────────┬───────────────────┘
           │                                 │
           │                                 ▼
           │                    ┌────────────────────────────────┐
           │                    │ BUY order fully filled?        │
           │                    ├────────────┬───────────────────┤
           │                    │    YES     │       NO          │
           │                    │  (FILLED)  │ (Add to book)     │
           │                    └────────────┴───────────────────┘
           │                                 │
           └─── SELL ───────────────────────┤
                                             │
                                             ▼
                                ┌────────────────────────────────┐
                                │ Get BUY orders for symbol      │
                                │ (sorted by price DESC)         │
                                └────────────┬───────────────────┘
                                             │
                                             ▼
                                ┌────────────────────────────────┐
                                │ For each BUY order:            │
                                │   If BUY price >= SELL price   │
                                │     → Execute Trade            │
                                │     → Update filled quantities │
                                │   Else: Stop matching          │
                                └────────────┬───────────────────┘
                                             │
                                             ▼
                                ┌────────────────────────────────┐
                                │ SELL order fully filled?       │
                                ├────────────┬───────────────────┤
                                │    YES     │       NO          │
                                │  (FILLED)  │ (Add to book)     │
                                └────────────┴───────────────────┘
                                             │
                                             ▼
                                ┌────────────────────────────────┐
                                │  Return Order + Trades Array   │
                                └────────────────────────────────┘
```

## Data Structures

### Order Object
```typescript
{
  id: "uuid",
  symbol: "AAPL",
  side: "BUY" | "SELL",
  price: 150.50,
  quantity: 100,
  filledQuantity: 50,
  status: "PENDING" | "PARTIALLY_FILLED" | "FILLED" | "CANCELLED",
  timestamp: 1234567890
}
```

### Trade Object
```typescript
{
  id: "uuid",
  symbol: "AAPL",
  buyOrderId: "buy-order-uuid",
  sellOrderId: "sell-order-uuid",
  price: 150.50,
  quantity: 50,
  timestamp: 1234567890
}
```

### Order Book Structure
```typescript
{
  symbol: "AAPL",
  bids: [
    { price: 150.50, quantity: 100, orderCount: 2 },
    { price: 150.00, quantity: 200, orderCount: 3 }
  ],
  asks: [
    { price: 151.00, quantity: 150, orderCount: 2 },
    { price: 151.50, quantity: 100, orderCount: 1 }
  ],
  timestamp: 1234567890
}
```

## Order Lifecycle

```
   ┌────────────┐
   │  CREATED   │
   └─────┬──────┘
         │
         ▼
   ┌────────────┐
   │  PENDING   │◄───────────────┐
   └─────┬──────┘                │
         │                       │
         │ Partial Match         │ More Matches
         ▼                       │
   ┌──────────────────┐          │
   │ PARTIALLY_FILLED │──────────┘
   └─────┬────────────┘
         │
         │ Full Match
         ▼
   ┌────────────┐
   │   FILLED   │
   └────────────┘

   At any point before FILLED:
   ┌────────────┐
   │ CANCELLED  │
   └────────────┘
```

## Matching Example

### Initial State
```
Order Book for AAPL:

BIDS (Buy Orders):          ASKS (Sell Orders):
$150.00 → 100 shares       $151.00 → 50 shares
$149.50 → 200 shares       $152.00 → 100 shares
```

### New Order Arrives
```
BUY Order: $151.50 x 75 shares
```

### Matching Process
```
Step 1: Check first SELL order ($151.00 x 50)
  - BUY price ($151.50) >= SELL price ($151.00) ✓
  - Match 50 shares
  - Trade 1: $151.00 x 50 shares

Step 2: Check next SELL order ($152.00 x 100)
  - BUY price ($151.50) >= SELL price ($152.00) ✗
  - No match, stop matching

Result:
  - BUY order: PARTIALLY_FILLED (50/75 filled)
  - Remaining 25 shares added to order book
  - 1 Trade executed
```

### Final State
```
Order Book for AAPL:

BIDS (Buy Orders):          ASKS (Sell Orders):
$151.50 → 25 shares ⭐     $152.00 → 100 shares
$150.00 → 100 shares       
$149.50 → 200 shares       

Trades:
  Trade 1: BUY $151.00 x 50 shares
```

## Project Structure Tree

```
Eterna_Labs/
├── src/
│   ├── engine/
│   │   ├── MatchingEngine.ts         # Core matching logic
│   │   └── MatchingEngine.test.ts    # Unit tests
│   ├── services/
│   │   └── OrderBookManager.ts       # Business logic
│   ├── routes/
│   │   └── index.ts                  # API endpoints
│   ├── middleware/
│   │   └── errorHandler.ts           # Error handling
│   ├── types/
│   │   └── index.ts                  # TypeScript types
│   └── index.ts                      # Server entry point
├── dist/                              # Compiled JavaScript
├── node_modules/                      # Dependencies
├── package.json                       # Project config
├── tsconfig.json                      # TypeScript config
├── jest.config.js                     # Test config
├── README.md                          # Full documentation
├── QUICKSTART.md                      # Quick start guide
├── PROJECT_SUMMARY.md                 # Project overview
├── DEMO_INSTRUCTIONS.md               # Demo script
├── ARCHITECTURE.md                    # This file
├── test-api.ps1                       # Test script
└── postman_collection.json            # Postman tests
```

## Technology Stack

```
┌─────────────────────────────────────────┐
│           Application Layer             │
│     ┌─────────────────────────────┐    │
│     │  Express.js REST API        │    │
│     └─────────────────────────────┘    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│          Business Logic Layer           │
│     ┌─────────────────────────────┐    │
│     │  Order Book Manager         │    │
│     └─────────────────────────────┘    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│            Core Engine Layer            │
│     ┌─────────────────────────────┐    │
│     │  Matching Engine            │    │
│     │  - Price-Time Priority      │    │
│     │  - Trade Execution          │    │
│     │  - Order Book Management    │    │
│     └─────────────────────────────┘    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│            Data Storage Layer           │
│     ┌─────────────────────────────┐    │
│     │  In-Memory Storage          │    │
│     │  - Maps (Orders)            │    │
│     │  - Arrays (Order Books)     │    │
│     │  - Arrays (Trades)          │    │
│     └─────────────────────────────┘    │
└─────────────────────────────────────────┘

         TypeScript + Node.js
```

## Performance Characteristics

| Operation | Time Complexity | Space Complexity |
|-----------|----------------|------------------|
| Submit Order | O(n) | O(1) |
| Match Order | O(m) | O(k) |
| Get Order | O(1) | O(1) |
| Get Order Book | O(p) | O(p) |
| Get Trades | O(1) | O(1) |
| Cancel Order | O(n) | O(1) |

Where:
- n = number of matching orders
- m = number of orders in symbol's order book
- k = number of trades executed
- p = number of price levels

## Scalability Considerations

### Current (Demo)
- In-memory storage
- Single process
- ~1000 orders/sec

### Production (Recommended)
- PostgreSQL for persistence
- Redis for caching
- Message Queue (RabbitMQ/Kafka)
- Horizontal scaling
- ~100,000+ orders/sec

---

**Built with ❤️ for Eterna Labs**
