# 🌐 Browser Dashboard Guide

## Overview
You now have a beautiful web-based dashboard to interact with the Order Execution Engine directly from your browser!

## Access the Dashboard

**URL**: http://localhost:3000

The dashboard will automatically open in your default browser.

## Features

### 1. **Create New Order Panel** (Top Left)
- Enter **Symbol** (e.g., AAPL, TSLA, GOOGL, NVDA)
- Enter **Price** in dollars (e.g., 150.00)
- Enter **Quantity** (e.g., 100)
- Click **🟢 BUY** or **🔴 SELL** button

**What happens:**
- Order is instantly created
- If it matches existing orders, trades are executed immediately
- Response shows order details and any trades executed
- Order book auto-refreshes if viewing the same symbol

### 2. **Quick Actions Panel** (Top Right)
- **📊 View Order Book** - Shows current bids and asks for a symbol
- **📋 View All Orders** - Lists all orders in the system
- **💰 View All Trades** - Shows all executed trades
- **❤️ Check Health** - Verifies server is running

### 3. **Order Book Display** (Middle)
- Shows aggregated bids (buy orders) in green
- Shows aggregated asks (sell orders) in red
- Displays price, quantity, and number of orders at each level

### 4. **Recent Orders** (Bottom Left)
- Lists up to 10 most recent orders
- Shows order status (PENDING, FILLED, PARTIALLY_FILLED)
- Color-coded by side (BUY=green, SELL=red)

### 5. **Recent Trades** (Bottom Right)
- Shows up to 10 most recent trades
- Displays symbol, price, and quantity
- Updates in real-time

## Usage Examples

### Example 1: Create a Simple Trade

1. In "Create New Order" panel:
   - Symbol: `AAPL`
   - Price: `150.00`
   - Quantity: `100`
   - Click **🔴 SELL**

2. Create a matching order:
   - Symbol: `AAPL`
   - Price: `150.00`
   - Quantity: `50`
   - Click **🟢 BUY**

3. ✅ Result: Trade executes immediately for 50 shares at $150!

### Example 2: View Market Depth

1. Enter symbol in "Quick Actions": `AAPL`
2. Click **📊 View Order Book**
3. See all pending buy and sell orders

### Example 3: Monitor Trading Activity

1. Click **📋 View All Orders** - See all orders
2. Click **💰 View All Trades** - See execution history
3. Dashboard auto-loads on page refresh

## Tips & Tricks

### 🎯 Best Practices
- Use uppercase symbols (e.g., AAPL, not aapl)
- Prices can have up to 2 decimal places
- Quantities can have up to 8 decimal places
- Green response = Success, Red response = Error

### 🔄 Real-Time Updates
- Order book refreshes after each order creation
- Orders and trades lists update when you click the buttons
- Page auto-loads recent data when opened

### 🎨 Color Coding
- **Green (BUY)** - Buy orders and bids
- **Red (SELL)** - Sell orders and asks
- **Blue (FILLED)** - Completely filled orders
- **Purple (PARTIALLY_FILLED)** - Partially filled orders
- **Yellow (PENDING)** - Waiting orders

### 🧪 Test Scenarios

#### Scenario 1: Complete Match
```
1. SELL AAPL @ $150 x 100
2. BUY AAPL @ $150 x 100
Result: Both orders filled completely!
```

#### Scenario 2: Partial Fill
```
1. SELL TSLA @ $250 x 150
2. BUY TSLA @ $250 x 75
Result: Buy order filled, Sell order 50% filled
```

#### Scenario 3: No Match (Price Gap)
```
1. SELL GOOGL @ $2900 x 50
2. BUY GOOGL @ $2800 x 50
Result: Both orders pending (no match)
```

#### Scenario 4: Aggressive Order
```
1. SELL NVDA @ $500 x 100
2. SELL NVDA @ $505 x 100
3. SELL NVDA @ $510 x 100
4. BUY NVDA @ $515 x 250
Result: Matches all 3 sell orders!
```

## Keyboard Shortcuts
- `Tab` - Navigate between fields
- `Enter` - Submit focused button
- `F5` - Refresh page and reload data

## Troubleshooting

### Dashboard won't load?
- Check server is running: http://localhost:3000/api/health
- Restart server: `npm run dev`

### Orders not creating?
- Check all fields are filled
- Verify price and quantity are positive numbers
- Check server console for errors

### Data not showing?
- Click the respective "View" buttons
- Check network tab in browser dev tools (F12)
- Verify API is responding: http://localhost:3000/api/health

## Browser Compatibility
- ✅ Chrome (Recommended)
- ✅ Firefox
- ✅ Edge
- ✅ Safari
- ✅ Opera

## Mobile Responsive
The dashboard is mobile-friendly and adapts to smaller screens!

## API Endpoints (For Reference)
All endpoints are available at `http://localhost:3000/api`:
- `POST /orders` - Create order
- `GET /orders` - Get all orders
- `GET /orders/:id` - Get specific order
- `DELETE /orders/:id` - Cancel order
- `GET /orderbook/:symbol` - Get order book
- `GET /trades` - Get all trades
- `GET /health` - Health check

## Next Steps

1. **Try creating orders** through the web interface
2. **Watch trades execute** in real-time
3. **View the order book** to understand market depth
4. **Use for your interview demo** - Impressive visual presentation!

---

**🎉 Enjoy your professional-grade trading dashboard!**

For API documentation, see: [README.md](README.md)
For demo script, see: [DEMO_INSTRUCTIONS.md](DEMO_INSTRUCTIONS.md)
