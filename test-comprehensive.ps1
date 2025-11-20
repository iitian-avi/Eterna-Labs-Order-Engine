# Comprehensive API Test - All Endpoints
$BASE_URL = "http://localhost:3000/api"

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  ORDER EXECUTION ENGINE - COMPREHENSIVE API TEST          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$testsPassed = 0
$testsFailed = 0

# Helper function to test API
function Test-Endpoint {
    param(
        [string]$TestName,
        [scriptblock]$TestScript
    )
    
    Write-Host "Testing: $TestName" -ForegroundColor Yellow
    try {
        & $TestScript
        Write-Host "PASSED: $TestName`n" -ForegroundColor Green
        $script:testsPassed++
        return $true
    }
    catch {
        Write-Host "FAILED: $TestName" -ForegroundColor Red
        Write-Host "  Error: $_`n" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
}

# TEST 1: Health Check
Test-Endpoint "1. Health Check Endpoint" {
    $response = Invoke-RestMethod -Uri "$BASE_URL/health" -Method GET
    if (-not $response.success) { throw "Health check failed" }
    Write-Host "  Status: $($response.data.status)" -ForegroundColor Cyan
    Write-Host "  Timestamp: $($response.data.timestamp)" -ForegroundColor Cyan
}

# TEST 2: Create SELL Order
$sellOrderId = $null
Test-Endpoint "2. POST /orders - Create SELL Order" {
    $order = @{
        symbol = "TSLA"
        side = "SELL"
        price = 250.50
        quantity = 150
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $order -ContentType "application/json"
    if (-not $response.success) { throw "Failed to create order" }
    
    $script:sellOrderId = $response.data.order.id
    Write-Host "  Order ID: $($response.data.order.id)" -ForegroundColor Cyan
    Write-Host "  Symbol: $($response.data.order.symbol)" -ForegroundColor Cyan
    Write-Host "  Side: $($response.data.order.side)" -ForegroundColor Cyan
    Write-Host "  Price: $($response.data.order.price)" -ForegroundColor Cyan
    Write-Host "  Quantity: $($response.data.order.quantity)" -ForegroundColor Cyan
    Write-Host "  Status: $($response.data.order.status)" -ForegroundColor Cyan
    Write-Host "  Trades: $($response.data.trades.Count)" -ForegroundColor Cyan
}

# TEST 3: Create BUY Order (Partial Match)
$buyOrderId = $null
Test-Endpoint "3. POST /orders - Create BUY Order (Should Match)" {
    $order = @{
        symbol = "TSLA"
        side = "BUY"
        price = 250.50
        quantity = 75
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $order -ContentType "application/json"
    if (-not $response.success) { throw "Failed to create order" }
    
    $script:buyOrderId = $response.data.order.id
    Write-Host "  Order ID: $($response.data.order.id)" -ForegroundColor Cyan
    Write-Host "  Status: $($response.data.order.status)" -ForegroundColor Cyan
    Write-Host "  Filled Quantity: $($response.data.order.filledQuantity)" -ForegroundColor Cyan
    Write-Host "  Trades Executed: $($response.data.trades.Count)" -ForegroundColor Cyan
    
    if ($response.data.trades.Count -eq 0) {
        throw "Expected trade to be executed but got none"
    }
    
    Write-Host "  Trade Price: $($response.data.trades[0].price)" -ForegroundColor Cyan
    Write-Host "  Trade Quantity: $($response.data.trades[0].quantity)" -ForegroundColor Cyan
}

# TEST 4: Get Specific Order by ID
Test-Endpoint "4. GET /orders/:id - Get Order By ID" {
    $response = Invoke-RestMethod -Uri "$BASE_URL/orders/$sellOrderId" -Method GET
    if (-not $response.success) { throw "Failed to get order" }
    
    Write-Host "  Order ID: $($response.data.id)" -ForegroundColor Cyan
    Write-Host "  Symbol: $($response.data.symbol)" -ForegroundColor Cyan
    Write-Host "  Status: $($response.data.status)" -ForegroundColor Cyan
    Write-Host "  Filled: $($response.data.filledQuantity)/$($response.data.quantity)" -ForegroundColor Cyan
}

# TEST 5: Get All Orders
Test-Endpoint "5. GET /orders - Get All Orders" {
    $response = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method GET
    if (-not $response.success) { throw "Failed to get orders" }
    
    Write-Host "  Total Orders: $($response.data.count)" -ForegroundColor Cyan
    foreach ($order in $response.data.orders) {
        Write-Host "    - $($order.symbol) $($order.side) @ $($order.price) x$($order.quantity) [$($order.status)]" -ForegroundColor Gray
    }
}

# TEST 6: Get Order Book
Test-Endpoint "6. GET /orderbook/:symbol - Get Order Book" {
    $response = Invoke-RestMethod -Uri "$BASE_URL/orderbook/TSLA" -Method GET
    if (-not $response.success) { throw "Failed to get order book" }
    
    Write-Host "  Symbol: $($response.data.symbol)" -ForegroundColor Cyan
    Write-Host "  Bids: $($response.data.bids.Count) levels" -ForegroundColor Cyan
    Write-Host "  Asks: $($response.data.asks.Count) levels" -ForegroundColor Cyan
    
    if ($response.data.bids.Count -gt 0) {
        Write-Host "  Best Bid: $($response.data.bids[0].price) x $($response.data.bids[0].quantity)" -ForegroundColor Gray
    }
    if ($response.data.asks.Count -gt 0) {
        Write-Host "  Best Ask: $($response.data.asks[0].price) x $($response.data.asks[0].quantity)" -ForegroundColor Gray
    }
}

# TEST 7: Get All Trades
Test-Endpoint "7. GET /trades - Get All Trades" {
    $response = Invoke-RestMethod -Uri "$BASE_URL/trades" -Method GET
    if (-not $response.success) { throw "Failed to get trades" }
    
    Write-Host "  Total Trades: $($response.data.count)" -ForegroundColor Cyan
    foreach ($trade in $response.data.trades) {
        Write-Host "    - $($trade.symbol): $($trade.price) x $($trade.quantity)" -ForegroundColor Gray
    }
}

# TEST 8: Create Order with Different Symbol
$nvdaOrderId = $null
Test-Endpoint "8. POST /orders - Multiple Symbols Support" {
    $order = @{
        symbol = "NVDA"
        side = "BUY"
        price = 500.00
        quantity = 50
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $order -ContentType "application/json"
    if (-not $response.success) { throw "Failed to create order" }
    
    $script:nvdaOrderId = $response.data.order.id
    Write-Host "  Order ID: $($response.data.order.id)" -ForegroundColor Cyan
    Write-Host "  Symbol: $($response.data.order.symbol)" -ForegroundColor Cyan
    Write-Host "  Status: $($response.data.order.status)" -ForegroundColor Cyan
}

# TEST 9: Get Order Book for Different Symbol
Test-Endpoint "9. GET /orderbook/:symbol - NVDA Order Book" {
    $response = Invoke-RestMethod -Uri "$BASE_URL/orderbook/NVDA" -Method GET
    if (-not $response.success) { throw "Failed to get order book" }
    
    Write-Host "  Symbol: $($response.data.symbol)" -ForegroundColor Cyan
    Write-Host "  Bids: $($response.data.bids.Count) levels" -ForegroundColor Cyan
    Write-Host "  Asks: $($response.data.asks.Count) levels" -ForegroundColor Cyan
}

# TEST 10: Create Multiple Orders at Same Price (Time Priority Test)
Test-Endpoint "10. POST /orders - Time Priority Test" {
    # Create first sell order
    $order1 = @{
        symbol = "AAPL"
        side = "SELL"
        price = 180.00
        quantity = 100
    } | ConvertTo-Json
    $response1 = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $order1 -ContentType "application/json"
    
    Start-Sleep -Milliseconds 100
    
    # Create second sell order at same price
    $order2 = @{
        symbol = "AAPL"
        side = "SELL"
        price = 180.00
        quantity = 100
    } | ConvertTo-Json
    $response2 = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $order2 -ContentType "application/json"
    
    # Create buy order - should match first order (time priority)
    $buyOrder = @{
        symbol = "AAPL"
        side = "BUY"
        price = 180.00
        quantity = 50
    } | ConvertTo-Json
    $buyResponse = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $buyOrder -ContentType "application/json"
    
    Write-Host "  First Sell Order: $($response1.data.order.id)" -ForegroundColor Cyan
    Write-Host "  Second Sell Order: $($response2.data.order.id)" -ForegroundColor Cyan
    Write-Host "  Buy Order matched with: $($buyResponse.data.trades[0].sellOrderId)" -ForegroundColor Cyan
    Write-Host "  Time priority verified: $(if ($buyResponse.data.trades[0].sellOrderId -eq $response1.data.order.id) { 'YES' } else { 'NO' })" -ForegroundColor Cyan
}

# TEST 11: Cancel Order
Test-Endpoint "11. DELETE /orders/:id - Cancel Order" {
    $response = Invoke-RestMethod -Uri "$BASE_URL/orders/$nvdaOrderId" -Method DELETE
    if (-not $response.success) { throw "Failed to cancel order" }
    
    Write-Host "  Cancelled Order ID: $nvdaOrderId" -ForegroundColor Cyan
    Write-Host "  Message: $($response.data.message)" -ForegroundColor Cyan
    
    # Verify order is cancelled
    $verifyResponse = Invoke-RestMethod -Uri "$BASE_URL/orders/$nvdaOrderId" -Method GET
    if ($verifyResponse.data.status -ne "CANCELLED") {
        throw "Order status is not CANCELLED"
    }
    Write-Host "  Verified Status: $($verifyResponse.data.status)" -ForegroundColor Cyan
}

# TEST 12: Validation - Invalid Symbol
Test-Endpoint "12. Validation - Empty Symbol (Should Fail)" {
    try {
        $order = @{
            symbol = ""
            side = "BUY"
            price = 100.00
            quantity = 10
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $order -ContentType "application/json" -ErrorAction Stop
        throw "Should have failed with empty symbol"
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            Write-Host "  Correctly rejected invalid symbol" -ForegroundColor Cyan
        }
        else {
            throw $_
        }
    }
}

# TEST 13: Validation - Invalid Side
Test-Endpoint "13. Validation - Invalid Side (Should Fail)" {
    try {
        $order = @{
            symbol = "TEST"
            side = "INVALID"
            price = 100.00
            quantity = 10
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $order -ContentType "application/json" -ErrorAction Stop
        throw "Should have failed with invalid side"
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            Write-Host "  Correctly rejected invalid side" -ForegroundColor Cyan
        }
        else {
            throw $_
        }
    }
}

# TEST 14: Validation - Negative Price
Test-Endpoint "14. Validation - Negative Price (Should Fail)" {
    try {
        $order = @{
            symbol = "TEST"
            side = "BUY"
            price = -100.00
            quantity = 10
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $order -ContentType "application/json" -ErrorAction Stop
        throw "Should have failed with negative price"
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            Write-Host "  Correctly rejected negative price" -ForegroundColor Cyan
        }
        else {
            throw $_
        }
    }
}

# TEST 15: Validation - Zero Quantity
Test-Endpoint "15. Validation - Zero Quantity (Should Fail)" {
    try {
        $order = @{
            symbol = "TEST"
            side = "BUY"
            price = 100.00
            quantity = 0
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $order -ContentType "application/json" -ErrorAction Stop
        throw "Should have failed with zero quantity"
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            Write-Host "  Correctly rejected zero quantity" -ForegroundColor Cyan
        }
        else {
            throw $_
        }
    }
}

# TEST 16: Price Priority Test
Test-Endpoint "16. Price Priority - Best Price Matches First" {
    # Create sell orders at different prices
    $sell1 = @{symbol="MSFT";side="SELL";price=350.00;quantity=100} | ConvertTo-Json
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $sell1 -ContentType "application/json" | Out-Null
    
    $sell2 = @{symbol="MSFT";side="SELL";price=345.00;quantity=100} | ConvertTo-Json
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $sell2 -ContentType "application/json" | Out-Null
    
    $sell3 = @{symbol="MSFT";side="SELL";price=340.00;quantity=100} | ConvertTo-Json
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $sell3 -ContentType "application/json" | Out-Null
    
    # Create buy order - should match with lowest price (340)
    $buy = @{symbol="MSFT";side="BUY";price=350.00;quantity=50} | ConvertTo-Json
    $buyResponse = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $buy -ContentType "application/json"
    
    Write-Host "  Created 3 sell orders: 350, 345, 340" -ForegroundColor Cyan
    Write-Host "  Buy order matched at: $($buyResponse.data.trades[0].price)" -ForegroundColor Cyan
    
    if ($buyResponse.data.trades[0].price -ne 340) {
        throw "Price priority not working - expected 340"
    }
    Write-Host "  Price priority verified!" -ForegroundColor Cyan
}

# TEST 17: Get Non-Existent Order
Test-Endpoint "17. GET /orders/:id - Non-Existent Order (Should Return 404)" {
    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/orders/non-existent-id" -Method GET -ErrorAction Stop
        throw "Should have returned 404"
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "  Correctly returned 404 for non-existent order" -ForegroundColor Cyan
        }
        else {
            throw $_
        }
    }
}

# TEST 18: Multiple Trades from Single Order
Test-Endpoint "18. Multiple Trades - Aggressive Order Matching" {
    # Create multiple sell orders
    $s1 = @{symbol="GOOG";side="SELL";price=140.00;quantity=50} | ConvertTo-Json
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $s1 -ContentType "application/json" | Out-Null
    
    $s2 = @{symbol="GOOG";side="SELL";price=141.00;quantity=50} | ConvertTo-Json
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $s2 -ContentType "application/json" | Out-Null
    
    $s3 = @{symbol="GOOG";side="SELL";price=142.00;quantity=50} | ConvertTo-Json
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $s3 -ContentType "application/json" | Out-Null
    
    # Create aggressive buy order
    $buy = @{symbol="GOOG";side="BUY";price=145.00;quantity=150} | ConvertTo-Json
    $buyResponse = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $buy -ContentType "application/json"
    
    Write-Host "  Created 3 sell orders" -ForegroundColor Cyan
    Write-Host "  Aggressive buy order matched: $($buyResponse.data.trades.Count) trades" -ForegroundColor Cyan
    
    if ($buyResponse.data.trades.Count -ne 3) {
        throw "Expected 3 trades but got $($buyResponse.data.trades.Count)"
    }
    
    Write-Host "  Trade 1: $($buyResponse.data.trades[0].price) x $($buyResponse.data.trades[0].quantity)" -ForegroundColor Gray
    Write-Host "  Trade 2: $($buyResponse.data.trades[1].price) x $($buyResponse.data.trades[1].quantity)" -ForegroundColor Gray
    Write-Host "  Trade 3: $($buyResponse.data.trades[2].price) x $($buyResponse.data.trades[2].quantity)" -ForegroundColor Gray
}

# Final Summary
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    TEST SUMMARY                            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -gt 0) { "Red" } else { "Green" })
Write-Host "Total Tests:  $($testsPassed + $testsFailed)" -ForegroundColor Cyan
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "The Order Execution Engine is fully functional!" -ForegroundColor Green
} else {
    Write-Host "Some tests failed. Please review the errors above." -ForegroundColor Yellow
}

Write-Host ""
