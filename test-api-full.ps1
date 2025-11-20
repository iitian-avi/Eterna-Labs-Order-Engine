# API Functionality Test Script
$BASE_URL = "http://localhost:3000/api"

Write-Host "`n====== ORDER EXECUTION ENGINE - API TEST ======`n" -ForegroundColor Cyan

$passed = 0
$failed = 0

# Test 1: Health Check
Write-Host "[TEST 1] Health Check..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$BASE_URL/health" -Method GET
    if ($health.success) {
        Write-Host "PASS - Server is healthy" -ForegroundColor Green
        $passed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 2: Create SELL Order
Write-Host "`n[TEST 2] Create SELL Order..." -ForegroundColor Yellow
try {
    $sellOrder = @{
        symbol = "TSLA"
        side = "SELL"
        price = 250.50
        quantity = 150
    } | ConvertTo-Json
    
    $sellResp = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $sellOrder -ContentType "application/json"
    if ($sellResp.success) {
        $sellId = $sellResp.data.order.id
        Write-Host "PASS - Order created: $sellId" -ForegroundColor Green
        Write-Host "  Symbol: $($sellResp.data.order.symbol)" -ForegroundColor Gray
        Write-Host "  Price: $($sellResp.data.order.price)" -ForegroundColor Gray
        Write-Host "  Quantity: $($sellResp.data.order.quantity)" -ForegroundColor Gray
        $passed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 3: Create BUY Order with Match
Write-Host "`n[TEST 3] Create BUY Order (should match)..." -ForegroundColor Yellow
try {
    $buyOrder = @{
        symbol = "TSLA"
        side = "BUY"
        price = 250.50
        quantity = 75
    } | ConvertTo-Json
    
    $buyResp = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $buyOrder -ContentType "application/json"
    if ($buyResp.success -and $buyResp.data.trades.Count -gt 0) {
        Write-Host "PASS - Order matched! Trade executed" -ForegroundColor Green
        Write-Host "  Order Status: $($buyResp.data.order.status)" -ForegroundColor Gray
        Write-Host "  Filled Quantity: $($buyResp.data.order.filledQuantity)" -ForegroundColor Gray
        Write-Host "  Trades: $($buyResp.data.trades.Count)" -ForegroundColor Gray
        $buyId = $buyResp.data.order.id
        $passed++
    } else {
        Write-Host "FAIL - No trade executed" -ForegroundColor Red
        $failed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 4: Get Order By ID
Write-Host "`n[TEST 4] Get Order By ID..." -ForegroundColor Yellow
try {
    $orderResp = Invoke-RestMethod -Uri "$BASE_URL/orders/$sellId" -Method GET
    if ($orderResp.success) {
        Write-Host "PASS - Order retrieved" -ForegroundColor Green
        Write-Host "  ID: $($orderResp.data.id)" -ForegroundColor Gray
        Write-Host "  Status: $($orderResp.data.status)" -ForegroundColor Gray
        $passed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 5: Get All Orders
Write-Host "`n[TEST 5] Get All Orders..." -ForegroundColor Yellow
try {
    $allOrders = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method GET
    if ($allOrders.success) {
        Write-Host "PASS - Retrieved $($allOrders.data.count) orders" -ForegroundColor Green
        $passed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 6: Get Order Book
Write-Host "`n[TEST 6] Get Order Book for TSLA..." -ForegroundColor Yellow
try {
    $orderBook = Invoke-RestMethod -Uri "$BASE_URL/orderbook/TSLA" -Method GET
    if ($orderBook.success) {
        Write-Host "PASS - Order book retrieved" -ForegroundColor Green
        Write-Host "  Bids: $($orderBook.data.bids.Count) levels" -ForegroundColor Gray
        Write-Host "  Asks: $($orderBook.data.asks.Count) levels" -ForegroundColor Gray
        $passed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 7: Get All Trades
Write-Host "`n[TEST 7] Get All Trades..." -ForegroundColor Yellow
try {
    $trades = Invoke-RestMethod -Uri "$BASE_URL/trades" -Method GET
    if ($trades.success) {
        Write-Host "PASS - Retrieved $($trades.data.count) trades" -ForegroundColor Green
        $passed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 8: Multiple Symbol Support
Write-Host "`n[TEST 8] Multiple Symbol Support (NVDA)..." -ForegroundColor Yellow
try {
    $nvdaOrder = @{
        symbol = "NVDA"
        side = "BUY"
        price = 500.00
        quantity = 50
    } | ConvertTo-Json
    
    $nvdaResp = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $nvdaOrder -ContentType "application/json"
    if ($nvdaResp.success) {
        $nvdaId = $nvdaResp.data.order.id
        Write-Host "PASS - Multi-symbol support works" -ForegroundColor Green
        $passed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 9: Cancel Order
Write-Host "`n[TEST 9] Cancel Order..." -ForegroundColor Yellow
try {
    $cancelResp = Invoke-RestMethod -Uri "$BASE_URL/orders/$nvdaId" -Method DELETE
    if ($cancelResp.success) {
        Write-Host "PASS - Order cancelled" -ForegroundColor Green
        $passed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 10: Validation - Invalid Symbol
Write-Host "`n[TEST 10] Validation - Empty Symbol (should fail)..." -ForegroundColor Yellow
try {
    $badOrder = @{symbol="";side="BUY";price=100;quantity=10} | ConvertTo-Json
    $badResp = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $badOrder -ContentType "application/json" -ErrorAction Stop
    Write-Host "FAIL - Should have rejected empty symbol" -ForegroundColor Red
    $failed++
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "PASS - Correctly rejected invalid input" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "FAIL - Wrong error code" -ForegroundColor Red
        $failed++
    }
}

# Test 11: Price Priority
Write-Host "`n[TEST 11] Price Priority Test..." -ForegroundColor Yellow
try {
    $s1 = @{symbol="AAPL";side="SELL";price=180;quantity=100} | ConvertTo-Json
    $s2 = @{symbol="AAPL";side="SELL";price=175;quantity=100} | ConvertTo-Json
    $s3 = @{symbol="AAPL";side="SELL";price=170;quantity=100} | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $s1 -ContentType "application/json" | Out-Null
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $s2 -ContentType "application/json" | Out-Null
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $s3 -ContentType "application/json" | Out-Null
    
    $b = @{symbol="AAPL";side="BUY";price=180;quantity=50} | ConvertTo-Json
    $bResp = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $b -ContentType "application/json"
    
    if ($bResp.data.trades[0].price -eq 170) {
        Write-Host "PASS - Price priority working (matched at lowest price: 170)" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "FAIL - Matched at wrong price: $($bResp.data.trades[0].price)" -ForegroundColor Red
        $failed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Test 12: Multiple Trades from Single Order
Write-Host "`n[TEST 12] Multiple Trades from Single Order..." -ForegroundColor Yellow
try {
    $m1 = @{symbol="GOOG";side="SELL";price=140;quantity=50} | ConvertTo-Json
    $m2 = @{symbol="GOOG";side="SELL";price=141;quantity=50} | ConvertTo-Json
    $m3 = @{symbol="GOOG";side="SELL";price=142;quantity=50} | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $m1 -ContentType "application/json" | Out-Null
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $m2 -ContentType "application/json" | Out-Null
    Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $m3 -ContentType "application/json" | Out-Null
    
    $mb = @{symbol="GOOG";side="BUY";price=145;quantity=150} | ConvertTo-Json
    $mbResp = Invoke-RestMethod -Uri "$BASE_URL/orders" -Method POST -Body $mb -ContentType "application/json"
    
    if ($mbResp.data.trades.Count -eq 3) {
        Write-Host "PASS - Matched 3 trades from single order" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "FAIL - Expected 3 trades, got $($mbResp.data.trades.Count)" -ForegroundColor Red
        $failed++
    }
} catch {
    Write-Host "FAIL - $_" -ForegroundColor Red
    $failed++
}

# Summary
Write-Host "`n====== TEST SUMMARY ======" -ForegroundColor Cyan
Write-Host "Tests Passed: $passed" -ForegroundColor Green
Write-Host "Tests Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host "Total Tests: $($passed + $failed)" -ForegroundColor White

if ($failed -eq 0) {
    Write-Host "`nALL TESTS PASSED! System is fully functional!" -ForegroundColor Green
} else {
    Write-Host "`nSome tests failed. Review errors above." -ForegroundColor Yellow
}

Write-Host ""
