# Example API Usage Script
# Make sure the server is running before executing these commands

$BASE_URL = "http://localhost:3000/api"

Write-Host "=== Order Execution Engine - Test Script ===" -ForegroundColor Green
Write-Host ""

# 1. Health Check
Write-Host "1. Health Check..." -ForegroundColor Cyan
curl -X GET "$BASE_URL/health" | ConvertFrom-Json | ConvertTo-Json
Write-Host ""

# 2. Create Sell Order
Write-Host "2. Creating SELL order for AAPL at $150 (100 shares)..." -ForegroundColor Cyan
$sellOrder = @{
    symbol = "AAPL"
    side = "SELL"
    price = 150.00
    quantity = 100
} | ConvertTo-Json

$response1 = curl -X POST "$BASE_URL/orders" `
    -H "Content-Type: application/json" `
    -d $sellOrder | ConvertFrom-Json
$response1 | ConvertTo-Json -Depth 10
$sellOrderId = $response1.data.order.id
Write-Host ""

# 3. Create Buy Order (will partially match)
Write-Host "3. Creating BUY order for AAPL at $150 (50 shares) - Should match!" -ForegroundColor Cyan
$buyOrder1 = @{
    symbol = "AAPL"
    side = "BUY"
    price = 150.00
    quantity = 50
} | ConvertTo-Json

$response2 = curl -X POST "$BASE_URL/orders" `
    -H "Content-Type: application/json" `
    -d $buyOrder1 | ConvertFrom-Json
$response2 | ConvertTo-Json -Depth 10
Write-Host ""

# 4. Check Order Book
Write-Host "4. Checking AAPL Order Book..." -ForegroundColor Cyan
curl -X GET "$BASE_URL/orderbook/AAPL" | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# 5. Get All Trades
Write-Host "5. Getting all trades..." -ForegroundColor Cyan
curl -X GET "$BASE_URL/trades" | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# 6. Create another Sell Order (different price)
Write-Host "6. Creating SELL order for AAPL at $152 (75 shares)..." -ForegroundColor Cyan
$sellOrder2 = @{
    symbol = "AAPL"
    side = "SELL"
    price = 152.00
    quantity = 75
} | ConvertTo-Json

$response3 = curl -X POST "$BASE_URL/orders" `
    -H "Content-Type: application/json" `
    -d $sellOrder2 | ConvertFrom-Json
$response3 | ConvertTo-Json -Depth 10
$sellOrderId2 = $response3.data.order.id
Write-Host ""

# 7. Create Buy Order (different symbol)
Write-Host "7. Creating BUY order for GOOGL at $2800 (25 shares)..." -ForegroundColor Cyan
$buyOrder2 = @{
    symbol = "GOOGL"
    side = "BUY"
    price = 2800.00
    quantity = 25
} | ConvertTo-Json

curl -X POST "$BASE_URL/orders" `
    -H "Content-Type: application/json" `
    -d $buyOrder2 | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# 8. Get All Orders
Write-Host "8. Getting all orders..." -ForegroundColor Cyan
curl -X GET "$BASE_URL/orders" | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# 9. Get Specific Order
Write-Host "9. Getting specific order: $sellOrderId..." -ForegroundColor Cyan
curl -X GET "$BASE_URL/orders/$sellOrderId" | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# 10. Cancel an Order
Write-Host "10. Cancelling order: $sellOrderId2..." -ForegroundColor Cyan
curl -X DELETE "$BASE_URL/orders/$sellOrderId2" | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# 11. Check AAPL Order Book Again
Write-Host "11. Checking AAPL Order Book after cancellation..." -ForegroundColor Cyan
curl -X GET "$BASE_URL/orderbook/AAPL" | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# 12. Create Aggressive Buy Order (should match multiple levels)
Write-Host "12. Creating aggressive BUY order for AAPL at $155 (200 shares)..." -ForegroundColor Cyan
$buyOrder3 = @{
    symbol = "AAPL"
    side = "BUY"
    price = 155.00
    quantity = 200
} | ConvertTo-Json

curl -X POST "$BASE_URL/orders" `
    -H "Content-Type: application/json" `
    -d $buyOrder3 | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# 13. Final Order Book Check
Write-Host "13. Final AAPL Order Book..." -ForegroundColor Cyan
curl -X GET "$BASE_URL/orderbook/AAPL" | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# 14. Final Trades Summary
Write-Host "14. Final trades summary..." -ForegroundColor Cyan
curl -X GET "$BASE_URL/trades" | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

Write-Host "=== Test Complete ===" -ForegroundColor Green
