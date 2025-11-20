# Order Execution Engine

A high-performance order matching engine that matches buy and sell orders in real-time using price-time priority.

## Features

- ✅ **Order Matching Engine** - Matches orders based on price-time priority
- ✅ **RESTful API** - Complete REST API for order management
- ✅ **Real-time Order Book** - Live order book with bid/ask aggregation
- ✅ **Trade Execution** - Automatic trade execution when orders match
- ✅ **Order Management** - Create, retrieve, and cancel orders
- ✅ **Partial Fills** - Support for partial order fills
- ✅ **Multiple Symbols** - Support for multiple trading symbols

## Tech Stack

- **Node.js** with **TypeScript**
- **Express.js** for REST API
- In-memory data storage (easily extendable to databases)
- Price-time priority matching algorithm

## Installation

```bash
# Install dependencies
npm install

# Build the project
npm run build

# Run in development mode
npm run dev

# Run in production mode
npm start
```

## API Endpoints

### 1. Create Order
Creates a new order and attempts to match it with existing orders.

**Endpoint:** `POST /api/orders`

**Request Body:**
```json
{
  "symbol": "AAPL",
  "side": "BUY",
  "price": 150.50,
  "quantity": 100
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "order": {
      "id": "uuid",
      "symbol": "AAPL",
      "side": "BUY",
      "price": 150.50,
      "quantity": 100,
      "filledQuantity": 50,
      "status": "PARTIALLY_FILLED",
      "timestamp": 1234567890
    },
    "trades": [
      {
        "id": "trade-uuid",
        "symbol": "AAPL",
        "buyOrderId": "buy-order-id",
        "sellOrderId": "sell-order-id",
        "price": 150.50,
        "quantity": 50,
        "timestamp": 1234567890
      }
    ]
  }
}
```

### 2. Get Order by ID
Retrieve a specific order by its ID.

**Endpoint:** `GET /api/orders/:id`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "symbol": "AAPL",
    "side": "BUY",
    "price": 150.50,
    "quantity": 100,
    "filledQuantity": 100,
    "status": "FILLED",
    "timestamp": 1234567890
  }
}
```

### 3. Get All Orders
Retrieve all orders in the system.

**Endpoint:** `GET /api/orders`

**Response:**
```json
{
  "success": true,
  "data": {
    "orders": [...],
    "count": 10
  }
}
```

### 4. Cancel Order
Cancel an existing order.

**Endpoint:** `DELETE /api/orders/:id`

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Order cancelled successfully",
    "orderId": "uuid"
  }
}
```

### 5. Get Order Book
Get the current order book for a symbol.

**Endpoint:** `GET /api/orderbook/:symbol`

**Response:**
```json
{
  "success": true,
  "data": {
    "symbol": "AAPL",
    "bids": [
      {
        "price": 150.50,
        "quantity": 100,
        "orderCount": 2
      }
    ],
    "asks": [
      {
        "price": 151.00,
        "quantity": 200,
        "orderCount": 3
      }
    ],
    "timestamp": 1234567890
  }
}
```

### 6. Get All Trades
Retrieve all executed trades.

**Endpoint:** `GET /api/trades`

**Response:**
```json
{
  "success": true,
  "data": {
    "trades": [...],
    "count": 5
  }
}
```

### 7. Health Check
Check if the service is running.

**Endpoint:** `GET /api/health`

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "timestamp": "2025-11-19T00:00:00.000Z"
  }
}
```

## Order Matching Logic

The engine uses **price-time priority** for matching orders:

1. **Price Priority**: Orders with better prices are matched first
   - For buy orders: Higher prices have priority
   - For sell orders: Lower prices have priority

2. **Time Priority**: If prices are equal, earlier orders are matched first

3. **Matching Process**:
   - When a BUY order arrives, it's matched against existing SELL orders
   - When a SELL order arrives, it's matched against existing BUY orders
   - Partial fills are supported
   - Unmatched portions remain in the order book

## Order Status

- `PENDING`: Order created but not yet filled
- `PARTIALLY_FILLED`: Order partially filled
- `FILLED`: Order completely filled
- `CANCELLED`: Order cancelled

## Example Usage

### Starting the Server

```bash
npm run dev
```

The server will start on `http://localhost:3000`

### Testing with cURL

#### Create a Buy Order
```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "AAPL",
    "side": "BUY",
    "price": 150.50,
    "quantity": 100
  }'
```

#### Create a Sell Order
```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "AAPL",
    "side": "SELL",
    "price": 150.00,
    "quantity": 50
  }'
```

#### Get Order Book
```bash
curl http://localhost:3000/api/orderbook/AAPL
```

#### Get All Trades
```bash
curl http://localhost:3000/api/trades
```

## Testing Scenarios

### Scenario 1: Complete Match
```bash
# Create sell order
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol": "AAPL", "side": "SELL", "price": 150.00, "quantity": 100}'

# Create matching buy order (will execute immediately)
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol": "AAPL", "side": "BUY", "price": 150.00, "quantity": 100}'
```

### Scenario 2: Partial Match
```bash
# Create sell order for 100 shares
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol": "AAPL", "side": "SELL", "price": 150.00, "quantity": 100}'

# Create buy order for 50 shares (partial match)
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol": "AAPL", "side": "BUY", "price": 150.00, "quantity": 50}'
```

### Scenario 3: No Match
```bash
# Create sell order at high price
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol": "AAPL", "side": "SELL", "price": 200.00, "quantity": 100}'

# Create buy order at low price (won't match)
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol": "AAPL", "side": "BUY", "price": 100.00, "quantity": 100}'
```

## Project Structure

```
src/
├── engine/
│   └── MatchingEngine.ts      # Core matching logic
├── services/
│   └── OrderBookManager.ts    # Order book management
├── routes/
│   └── index.ts               # API routes
├── middleware/
│   └── errorHandler.ts        # Error handling
├── types/
│   └── index.ts               # TypeScript types
└── index.ts                   # Entry point
```

## Error Handling

All errors follow a consistent format:

```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE"
  }
}
```

Common error codes:
- `VALIDATION_ERROR`: Invalid input data
- `ORDER_NOT_FOUND`: Order ID doesn't exist
- `CANCEL_FAILED`: Cannot cancel order
- `INTERNAL_ERROR`: Server error

## Validation Rules

- **Symbol**: Required, non-empty string
- **Side**: Must be "BUY" or "SELL"
- **Price**: Positive number, max 2 decimal places
- **Quantity**: Positive number, max 8 decimal places

## Future Enhancements

- [ ] Add database persistence (PostgreSQL/MongoDB)
- [ ] WebSocket support for real-time updates
- [ ] Order types (Market, Limit, Stop-Loss)
- [ ] Authentication and authorization
- [ ] Rate limiting
- [ ] Trading pairs management
- [ ] Historical data and analytics
- [ ] Performance monitoring

## License

MIT

## Author

Created for Eterna Labs Technical Assessment
