# Position Tracking Feature

## Overview

The Order Execution Engine now includes **position tracking** to prevent users from selling more shares than they own, preventing short selling.

## How It Works

### 1. Initial Positions
When the system starts with position tracking enabled, each user gets an initial balance:
- **AAPL**: 1,000 shares
- **TSLA**: 1,000 shares  
- **GOOGL**: 1,000 shares

### 2. Buy Orders
When you place a **BUY** order:
- If the order matches and gets filled, your position **increases**
- If the order is pending, position doesn't change yet

### 3. Sell Orders  
When you place a **SELL** order:
- System **checks** if you have enough shares
- If insufficient, order is **rejected** with error
- If sufficient, position **decreases immediately**
- This prevents selling the same shares twice

## API Endpoints

### Get User Positions
```http
GET /api/positions?userId=default
```

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": "default",
    "positions": [
      {
        "symbol": "AAPL",
        "quantity": 950
      },
      {
        "symbol": "TSLA",
        "quantity": 1000
      },
      {
        "symbol": "GOOGL",
        "quantity": 1000
      }
    ],
    "enforcePositions": true
  }
}
```

### Create Order (with position check)
```http
POST /api/orders
Content-Type: application/json

{
  "symbol": "AAPL",
  "side": "SELL",
  "price": 150.00,
  "quantity": 100
}
```

**Success Response (sufficient position):**
```json
{
  "success": true,
  "data": {
    "order": {
      "id": "...",
      "symbol": "AAPL",
      "side": "SELL",
      "status": "PENDING",
      ...
    },
    "trades": []
  }
}
```

**Error Response (insufficient position):**
```json
{
  "success": false,
  "error": {
    "message": "Insufficient position. You have 50 AAPL, but trying to sell 100",
    "code": "VALIDATION_ERROR"
  }
}
```

## Testing

Run the position tracking test:
```powershell
.\test-positions.ps1
```

**Test Flow:**
1. ✅ Check initial positions (1000 of each)
2. ✅ Buy 100 AAPL shares
3. ✅ Sell 50 AAPL shares (succeeds)
4. ✅ Try to sell 2000 AAPL shares (fails - insufficient)
5. ✅ Verify final positions

## Configuration

Position tracking is configured in `src/routes/index.ts`:

```typescript
// Enable position tracking
const orderBookManager = new OrderBookManager(true);

// Disable position tracking (allow short selling)
const orderBookManager = new OrderBookManager(false);
```

## Architecture

### PositionManager Class
Located in: `src/services/PositionManager.ts`

**Key Methods:**
- `getPosition(userId, symbol)` - Get current position
- `getUserPositions(userId)` - Get all positions
- `canSell(userId, symbol, quantity)` - Check if sale is allowed
- `updatePosition(userId, symbol, quantity, isBuy)` - Update after trade
- `giveInitialBalance(userId, symbol, quantity)` - Set initial balance

### OrderBookManager Integration
Located in: `src/services/OrderBookManager.ts`

**Logic:**
1. Validate order inputs
2. **Check position for SELL orders**
3. Submit order to matching engine
4. **Update position based on execution**

## Real-World Considerations

### Current Implementation (Demo)
- ✅ Single default user
- ✅ In-memory storage
- ✅ Simple validation
- ✅ Perfect for demo/interview

### Production Enhancements
- [ ] Multi-user support with authentication
- [ ] Database persistence (PostgreSQL/MongoDB)
- [ ] Cash balance tracking (not just shares)
- [ ] Margin accounts (allow controlled short selling)
- [ ] Position history and audit trail
- [ ] Real-time position updates via WebSocket
- [ ] Risk management (position limits, exposure limits)

## Benefits

### 1. Prevents Invalid Trades
❌ **Before:** Could sell unlimited shares  
✅ **After:** Can only sell what you own

### 2. Realistic Trading Simulation
Mimics real broker behavior where you must own shares to sell them.

### 3. Interview/Demo Ready
Shows understanding of:
- Financial systems
- Business logic validation
- State management
- Error handling

## Examples

### Example 1: Normal Trading Flow
```bash
# 1. Check positions
curl http://localhost:3000/api/positions

# 2. Sell 100 shares (succeeds)
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol":"AAPL","side":"SELL","price":150,"quantity":100}'

# 3. Position now: 900 AAPL
curl http://localhost:3000/api/positions
```

### Example 2: Insufficient Position (Error)
```bash
# Try to sell 2000 shares (only have 1000)
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"symbol":"AAPL","side":"SELL","price":150,"quantity":2000}'

# Response: 400 Bad Request
# "Insufficient position. You have 1000 AAPL, but trying to sell 2000"
```

## Toggle Feature On/Off

### Enable Position Tracking (Prevent Short Selling)
Edit `src/routes/index.ts`:
```typescript
const orderBookManager = new OrderBookManager(true);
```

### Disable Position Tracking (Allow Short Selling)
Edit `src/routes/index.ts`:
```typescript
const orderBookManager = new OrderBookManager(false);
```

Rebuild and restart:
```powershell
npm run build
npm run dev
```

## Summary

✅ **Position tracking** prevents overselling  
✅ **Validation errors** return clear messages  
✅ **Test suite** demonstrates functionality  
✅ **Configurable** - can enable/disable  
✅ **Production-ready** architecture  

---

**Note:** In production, you'd typically integrate with a proper user management system, database, and add cash balance tracking. This implementation demonstrates the core concept for interview/demo purposes.
