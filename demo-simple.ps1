# Simple Demo Script - Order Execution Engine
$BASE_URL = "http://localhost:3000/api"

Write-Host "`n=== ORDER EXECUTION ENGINE DEMO ===`n" -ForegroundColor Cyan

# 1. Health Check
Write-Host "1. Health Check..." -ForegroundColor Green
$health = Invoke-RestMethod -Uri "$BASE_URL/health" -Method GET
Write-Host "Status: Healthy`n" -ForegroundColor Green

# 2. Create SELL order
Write-Host "2. Creating SELL order for AAPL..." -ForegroundColor Green
$sellOrder = @{
    symbol = "AAPL"
    side = "SELL"
    price = 150.00
    quantity = 100
} | ConvertTo-Json

$sellResponse = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $sellOrder -ContentType "application/json"
Write-Host "Order ID: $($sellResponse.data.order.id)" -ForegroundColor Yellow
Write-Host "Status: $($sellResponse.data.order.status)`n" -ForegroundColor Yellow

# 3. Create BUY order (partial match)
Write-Host "3. Creating BUY order for AAPL - Should MATCH!" -ForegroundColor Green
$buyOrder = @{
    symbol = "AAPL"
    side = "BUY"
    price = 150.00
    quantity = 50
} | ConvertTo-Json

$buyResponse = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $buyOrder -ContentType "application/json"
Write-Host "Order Status: $($buyResponse.data.order.status)" -ForegroundColor Yellow
Write-Host "Filled Quantity: $($buyResponse.data.order.filledQuantity)" -ForegroundColor Yellow
Write-Host "Trades executed: $($buyResponse.data.trades.Count)" -ForegroundColor Yellow
if ($buyResponse.data.trades.Count -gt 0) {
    Write-Host "Trade Details:" -ForegroundColor Cyan
    $buyResponse.data.trades | ConvertTo-Json -Depth 10
}
Write-Host ""

# 4. Check Order Book
Write-Host "4. Checking AAPL Order Book..." -ForegroundColor Green
$orderBook = Invoke-RestMethod -Uri "$BASE_URL/orderbook/AAPL" -Method GET
Write-Host "Bids: $($orderBook.data.bids.Count) levels" -ForegroundColor Yellow
Write-Host "Asks: $($orderBook.data.asks.Count) levels" -ForegroundColor Yellow
if ($orderBook.data.asks.Count -gt 0) {
    Write-Host "Order Book:" -ForegroundColor Cyan
    $orderBook.data | ConvertTo-Json -Depth 10
}
Write-Host ""

# 5. Get All Trades
Write-Host "5. Getting All Trades..." -ForegroundColor Green
$trades = Invoke-RestMethod -Uri "$BASE_URL/trades" -Method GET
Write-Host "Total Trades: $($trades.data.count)" -ForegroundColor Yellow
Write-Host "Trade Details:" -ForegroundColor Cyan
$trades.data.trades | ConvertTo-Json -Depth 10
Write-Host ""

# 6. Create another SELL order
Write-Host "6. Creating another SELL order for AAPL..." -ForegroundColor Green
$sellOrder2 = @{
    symbol = "AAPL"
    side = "SELL"
    price = 152.00
    quantity = 75
} | ConvertTo-Json

$sellResponse2 = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $sellOrder2 -ContentType "application/json"
Write-Host "Order ID: $($sellResponse2.data.order.id)`n" -ForegroundColor Yellow

# 7. Create BUY order for different symbol
Write-Host "7. Creating BUY order for GOOGL..." -ForegroundColor Green
$buyOrder2 = @{
    symbol = "GOOGL"
    side = "BUY"
    price = 2800.00
    quantity = 25
} | ConvertTo-Json

$buyResponse2 = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $buyOrder2 -ContentType "application/json"
Write-Host "Order ID: $($buyResponse2.data.order.id)`n" -ForegroundColor Yellow

# 8. Get All Orders
Write-Host "8. Getting All Orders..." -ForegroundColor Green
$allOrders = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method GET
Write-Host "Total Orders: $($allOrders.data.count)" -ForegroundColor Yellow
Write-Host "Order Summary:" -ForegroundColor Cyan
foreach ($order in $allOrders.data.orders) {
    Write-Host "  - $($order.symbol) $($order.side) Price:$($order.price) Qty:$($order.quantity) Status:$($order.status)" -ForegroundColor White
}
Write-Host ""

# 9. Create aggressive BUY order
Write-Host "9. Creating aggressive BUY order for AAPL..." -ForegroundColor Green
$aggressiveBuy = @{
    symbol = "AAPL"
    side = "BUY"
    price = 155.00
    quantity = 200
} | ConvertTo-Json

$aggResponse = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $aggressiveBuy -ContentType "application/json"
Write-Host "Order Status: $($aggResponse.data.order.status)" -ForegroundColor Yellow
Write-Host "Filled Quantity: $($aggResponse.data.order.filledQuantity)" -ForegroundColor Yellow
Write-Host "Trades executed: $($aggResponse.data.trades.Count)" -ForegroundColor Yellow
if ($aggResponse.data.trades.Count -gt 0) {
    Write-Host "Trade Details:" -ForegroundColor Cyan
    foreach ($trade in $aggResponse.data.trades) {
        Write-Host "  - Trade at Price:$($trade.price) for Quantity:$($trade.quantity) shares" -ForegroundColor White
    }
}
Write-Host ""

# 10. Final Order Book
Write-Host "10. Final AAPL Order Book..." -ForegroundColor Green
$finalOrderBook = Invoke-RestMethod -Uri "$BASE_URL/orderbook/AAPL" -Method GET
Write-Host "Bids:" -ForegroundColor Cyan
foreach ($bid in $finalOrderBook.data.bids) {
    Write-Host "  Price:$($bid.price) x Qty:$($bid.quantity) Orders:$($bid.orderCount)" -ForegroundColor White
}
Write-Host "Asks:" -ForegroundColor Cyan
foreach ($ask in $finalOrderBook.data.asks) {
    Write-Host "  Price:$($ask.price) x Qty:$($ask.quantity) Orders:$($ask.orderCount)" -ForegroundColor White
}
Write-Host ""

# 11. Final Trade Summary
Write-Host "11. Final Trade Summary..." -ForegroundColor Green
$finalTrades = Invoke-RestMethod -Uri "$BASE_URL/trades" -Method GET
Write-Host "Total Trades Executed: $($finalTrades.data.count)" -ForegroundColor Green
Write-Host "Trade History:" -ForegroundColor Cyan
foreach ($trade in $finalTrades.data.trades) {
    Write-Host "  - $($trade.symbol): Price:$($trade.price) x Qty:$($trade.quantity) shares" -ForegroundColor White
}

Write-Host "`n=== DEMO COMPLETE ===`n" -ForegroundColor Cyan
