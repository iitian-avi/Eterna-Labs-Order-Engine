# Quick Start Guide

This guide will help you get the Order Execution Engine up and running quickly.

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- PowerShell (Windows) or bash (Mac/Linux)

## Installation Steps

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Build the Project**
   ```bash
   npm run build
   ```

3. **Start the Server**
   
   For development (with auto-reload):
   ```bash
   npm run dev
   ```
   
   For production:
   ```bash
   npm start
   ```

   The server will start on http://localhost:3000

## Quick Test

Once the server is running, you can test it with:

### Using PowerShell (Windows)
```powershell
.\test-api.ps1
```

### Using cURL (Mac/Linux/Windows)

```bash
# Create a sell order
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol":"AAPL","side":"SELL","price":150.00,"quantity":100}'

# Create a matching buy order
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol":"AAPL","side":"BUY","price":150.00,"quantity":50}'

# Check the order book
curl http://localhost:3000/api/orderbook/AAPL

# View all trades
curl http://localhost:3000/api/trades
```

## Key Features Demonstrated

1. **Order Creation**: Submit buy and sell orders
2. **Automatic Matching**: Orders are matched based on price-time priority
3. **Partial Fills**: Orders can be partially filled
4. **Order Book**: View aggregated bids and asks
5. **Trade History**: Track all executed trades
6. **Order Management**: Cancel pending orders

## Testing Scenarios

### Scenario 1: Complete Match
Both orders fully filled when they match exactly.

### Scenario 2: Partial Fill
Buyer wants 50 shares, seller offers 100 shares. Buyer gets filled completely, seller has 50 shares remaining.

### Scenario 3: Price Priority
Multiple orders at different prices. Best prices get matched first.

### Scenario 4: Time Priority
Multiple orders at the same price. Earlier orders get matched first.

## API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/orders | Create new order |
| GET | /api/orders/:id | Get order by ID |
| GET | /api/orders | Get all orders |
| DELETE | /api/orders/:id | Cancel order |
| GET | /api/orderbook/:symbol | Get order book |
| GET | /api/trades | Get all trades |
| GET | /api/health | Health check |

## Common Issues

### Port Already in Use
If port 3000 is busy, set a different port:
```bash
PORT=3001 npm run dev
```

### TypeScript Errors
Make sure dependencies are installed:
```bash
npm install
```

### Module Not Found
Rebuild the project:
```bash
npm run build
```

## Next Steps

- Read the full [README.md](README.md) for detailed API documentation
- Explore the code in the `src/` directory
- Run tests with `npm test` (after installing dependencies)
- Modify matching logic in `src/engine/MatchingEngine.ts`

## Support

For questions or issues, please refer to:
- Full API documentation in README.md
- Example test script: test-api.ps1
- Source code comments in the src/ directory
