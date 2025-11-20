# Test Position Tracking

Write-Host "`n=== Testing Position Tracking Feature ===" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000/api"

# 1. Check initial positions
Write-Host "`n1. Checking initial positions..." -ForegroundColor Yellow
try {
    $positions = Invoke-RestMethod -Uri "$baseUrl/positions" -Method GET
    Write-Host "Initial Positions:" -ForegroundColor Green
    $positions.data.positions | ForEach-Object {
        Write-Host "  $($_.symbol): $($_.quantity) shares"
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

# 2. Buy 100 AAPL shares
Write-Host "`n2. Buying 100 AAPL shares at `$150..." -ForegroundColor Yellow
try {
    $buyOrder = @{
        symbol = "AAPL"
        side = "BUY"
        price = 150.00
        quantity = 100
    } | ConvertTo-Json

    $result = Invoke-RestMethod -Uri "$baseUrl/orders" -Method POST -Body $buyOrder -ContentType "application/json"
    Write-Host "Order created: $($result.data.order.id)" -ForegroundColor Green
    Write-Host "Status: $($result.data.order.status)"
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

# 3. Check positions after buy
Write-Host "`n3. Checking positions after buy..." -ForegroundColor Yellow
try {
    $positions = Invoke-RestMethod -Uri "$baseUrl/positions" -Method GET
    Write-Host "Current Positions:" -ForegroundColor Green
    $positions.data.positions | ForEach-Object {
        Write-Host "  $($_.symbol): $($_.quantity) shares"
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

# 4. Try to sell 50 AAPL (should work - we have enough)
Write-Host "`n4. Selling 50 AAPL shares (should succeed)..." -ForegroundColor Yellow
try {
    $sellOrder = @{
        symbol = "AAPL"
        side = "SELL"
        price = 151.00
        quantity = 50
    } | ConvertTo-Json

    $result = Invoke-RestMethod -Uri "$baseUrl/orders" -Method POST -Body $sellOrder -ContentType "application/json"
    Write-Host "SUCCESS: Order created" -ForegroundColor Green
    Write-Host "Order ID: $($result.data.order.id)"
    Write-Host "Status: $($result.data.order.status)"
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

# 5. Check positions after sell
Write-Host "`n5. Checking positions after sell..." -ForegroundColor Yellow
try {
    $positions = Invoke-RestMethod -Uri "$baseUrl/positions" -Method GET
    Write-Host "Current Positions:" -ForegroundColor Green
    $positions.data.positions | ForEach-Object {
        Write-Host "  $($_.symbol): $($_.quantity) shares"
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

# 6. Try to sell 2000 AAPL (should FAIL - insufficient position)
Write-Host "`n6. Trying to sell 2000 AAPL shares (should FAIL)..." -ForegroundColor Yellow
try {
    $sellOrder = @{
        symbol = "AAPL"
        side = "SELL"
        price = 152.00
        quantity = 2000
    } | ConvertTo-Json

    $result = Invoke-RestMethod -Uri "$baseUrl/orders" -Method POST -Body $sellOrder -ContentType "application/json"
    Write-Host "ERROR: This should have failed!" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "SUCCESS: Order rejected as expected!" -ForegroundColor Green
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Error message: $($errorResponse.error.message)" -ForegroundColor Yellow
    } else {
        Write-Host "Unexpected error: $_" -ForegroundColor Red
    }
}

# 7. Final positions
Write-Host "`n7. Final positions..." -ForegroundColor Yellow
try {
    $positions = Invoke-RestMethod -Uri "$baseUrl/positions" -Method GET
    Write-Host "Final Positions:" -ForegroundColor Green
    $positions.data.positions | ForEach-Object {
        Write-Host "  $($_.symbol): $($_.quantity) shares"
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host "`n=== Position Tracking Test Complete ===" -ForegroundColor Cyan
