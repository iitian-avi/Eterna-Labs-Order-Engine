# Quick Demo Script
$BASE_URL = "http://localhost:3000/api"

Write-Host "`n=== ORDER EXECUTION ENGINE DEMO ===" -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# 1. Health Check
Write-Host "1. Health Check..." -ForegroundColor Green
try {
    $health = Invoke-RestMethod -Uri "$BASE_URL/health" -Method GET
    Write-Host "✓ Server is healthy!" -ForegroundColor Green
    $health | ConvertTo-Json
} catch {
    Write-Host "✗ Health check failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 2. Create SELL order
Write-Host "2. Creating SELL order for AAPL at $150 (100 shares)..." -ForegroundColor Green
$sellOrder = @{
    symbol = "AAPL"
    side = "SELL"
    price = 150.00
    quantity = 100
} | ConvertTo-Json

try {
    $sellResponse = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $sellOrder -ContentType "application/json"
    Write-Host "✓ Sell order created!" -ForegroundColor Green
    $sellOrderId = $sellResponse.data.order.id
    Write-Host "Order ID: $sellOrderId" -ForegroundColor Yellow
    Write-Host "Status: $($sellResponse.data.order.status)" -ForegroundColor Yellow
    Write-Host "Trades executed: $($sellResponse.data.trades.Count)" -ForegroundColor Yellow
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 3. Create BUY order (partial match)
Write-Host "3. Creating BUY order for AAPL at $150 (50 shares) - Should MATCH!" -ForegroundColor Green
$buyOrder = @{
    symbol = "AAPL"
    side = "BUY"
    price = 150.00
    quantity = 50
} | ConvertTo-Json

try {
    $buyResponse = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $buyOrder -ContentType "application/json"
    Write-Host "✓ Buy order created and MATCHED!" -ForegroundColor Green
    Write-Host "Order Status: $($buyResponse.data.order.status)" -ForegroundColor Yellow
    Write-Host "Filled Quantity: $($buyResponse.data.order.filledQuantity)" -ForegroundColor Yellow
    Write-Host "Trades executed: $($buyResponse.data.trades.Count)" -ForegroundColor Yellow
    if ($buyResponse.data.trades.Count -gt 0) {
        Write-Host "Trade Price: `$$($buyResponse.data.trades[0].price)" -ForegroundColor Cyan
        Write-Host "Trade Quantity: $($buyResponse.data.trades[0].quantity)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 4. Check Order Book
Write-Host "4. Checking AAPL Order Book..." -ForegroundColor Green
try {
    $orderBook = Invoke-RestMethod -Uri "$BASE_URL/orderbook/AAPL" -Method GET
    Write-Host "✓ Order Book Retrieved!" -ForegroundColor Green
    Write-Host "Bids (Buy orders): $($orderBook.data.bids.Count) levels" -ForegroundColor Yellow
    Write-Host "Asks (Sell orders): $($orderBook.data.asks.Count) levels" -ForegroundColor Yellow
    if ($orderBook.data.asks.Count -gt 0) {
        Write-Host "Best Ask: `$$($orderBook.data.asks[0].price) x $($orderBook.data.asks[0].quantity)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 5. Get All Trades
Write-Host "5. Getting All Trades..." -ForegroundColor Green
try {
    $trades = Invoke-RestMethod -Uri "$BASE_URL/trades" -Method GET
    Write-Host "✓ Trades Retrieved!" -ForegroundColor Green
    Write-Host "Total Trades: $($trades.data.count)" -ForegroundColor Yellow
    $trades.data.trades | ConvertTo-Json -Depth 10
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 6. Create another SELL order (different price)
Write-Host "6. Creating SELL order for AAPL at $152 (75 shares)..." -ForegroundColor Green
$sellOrder2 = @{
    symbol = "AAPL"
    side = "SELL"
    price = 152.00
    quantity = 75
} | ConvertTo-Json

try {
    $sellResponse2 = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $sellOrder2 -ContentType "application/json"
    Write-Host "✓ Sell order created!" -ForegroundColor Green
    $sellOrderId2 = $sellResponse2.data.order.id
    Write-Host "Order ID: $sellOrderId2" -ForegroundColor Yellow
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 7. Create BUY order for different symbol
Write-Host "7. Creating BUY order for GOOGL at $2800 (25 shares)..." -ForegroundColor Green
$buyOrder2 = @{
    symbol = "GOOGL"
    side = "BUY"
    price = 2800.00
    quantity = 25
} | ConvertTo-Json

try {
    $buyResponse2 = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $buyOrder2 -ContentType "application/json"
    Write-Host "✓ Buy order created!" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 8. Get All Orders
Write-Host "8. Getting All Orders..." -ForegroundColor Green
try {
    $allOrders = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method GET
    Write-Host "✓ All Orders Retrieved!" -ForegroundColor Green
    Write-Host "Total Orders: $($allOrders.data.count)" -ForegroundColor Yellow
    Write-Host "`nOrder Summary:" -ForegroundColor Cyan
    foreach ($order in $allOrders.data.orders) {
        Write-Host "  - $($order.symbol) $($order.side) `$$($order.price) x $($order.quantity) [$($order.status)]" -ForegroundColor White
    }
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 9. Create aggressive BUY order (should match multiple)
Write-Host "9. Creating aggressive BUY order for AAPL at $155 (200 shares)..." -ForegroundColor Green
$aggressiveBuy = @{
    symbol = "AAPL"
    side = "BUY"
    price = 155.00
    quantity = 200
} | ConvertTo-Json

try {
    $aggResponse = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $aggressiveBuy -ContentType "application/json"
    Write-Host "✓ Aggressive buy order executed!" -ForegroundColor Green
    Write-Host "Order Status: $($aggResponse.data.order.status)" -ForegroundColor Yellow
    Write-Host "Filled Quantity: $($aggResponse.data.order.filledQuantity)" -ForegroundColor Yellow
    Write-Host "Trades executed: $($aggResponse.data.trades.Count)" -ForegroundColor Yellow
    Write-Host "`nTrade Details:" -ForegroundColor Cyan
    foreach ($trade in $aggResponse.data.trades) {
        Write-Host "  - Trade at `$$($trade.price) for $($trade.quantity) shares" -ForegroundColor White
    }
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 10. Final Order Book
Write-Host "10. Final AAPL Order Book..." -ForegroundColor Green
try {
    $finalOrderBook = Invoke-RestMethod -Uri "$BASE_URL/orderbook/AAPL" -Method GET
    Write-Host "✓ Final Order Book Retrieved!" -ForegroundColor Green
    Write-Host "`nBids:" -ForegroundColor Cyan
    foreach ($bid in $finalOrderBook.data.bids) {
        Write-Host "  `$$($bid.price) x $($bid.quantity) ($($bid.orderCount) orders)" -ForegroundColor White
    }
    Write-Host "`nAsks:" -ForegroundColor Cyan
    foreach ($ask in $finalOrderBook.data.asks) {
        Write-Host "  `$$($ask.price) x $($ask.quantity) ($($ask.orderCount) orders)" -ForegroundColor White
    }
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}
Write-Host "`n"

# 11. Final Trade Summary
Write-Host "11. Final Trade Summary..." -ForegroundColor Green
try {
    $finalTrades = Invoke-RestMethod -Uri "$BASE_URL/trades" -Method GET
    Write-Host "✓ Total Trades Executed: $($finalTrades.data.count)" -ForegroundColor Green
    Write-Host "`nTrade History:" -ForegroundColor Cyan
    foreach ($trade in $finalTrades.data.trades) {
        Write-Host "  - $($trade.symbol): `$$($trade.price) x $($trade.quantity) shares" -ForegroundColor White
    }
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

Write-Host "`n=== DEMO COMPLETE ===" -ForegroundColor Cyan
Write-Host "All features demonstrated successfully!`n" -ForegroundColor Green
