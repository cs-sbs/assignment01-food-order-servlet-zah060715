$baseUrl = "http://localhost:8080"
$score = 0
$failed = 0

function Test-Endpoint {
    param($Name, $Url, $ExpectedStatus, $ExpectedBodyPattern)
    
    Write-Host "Running Test: $Name... " -NoNewline
    
    $tmpFile = [System.IO.Path]::GetTempFileName()
    $statusFile = [System.IO.Path]::GetTempFileName()
    
    try {
        curl.exe -s -o $tmpFile -w "%{http_code}" $Url | Out-File -FilePath $statusFile -NoNewline
        $status = Get-Content $statusFile
        $body = Get-Content $tmpFile -Raw
        
        if ($status -eq $ExpectedStatus -and $body -match $ExpectedBodyPattern) {
            Write-Host "PASS" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAIL (Status: $status, Body: $body)" -ForegroundColor Red
            return $false
        }
    } finally {
        if (Test-Path $tmpFile) { Remove-Item $tmpFile }
        if (Test-Path $statusFile) { Remove-Item $statusFile }
    }
}

function Test-PostEndpoint {
    param($Name, $Url, $Data, $ExpectedStatus, $ExpectedBodyPattern)
    
    Write-Host "Running Test: $Name... " -NoNewline
    
    $tmpFile = [System.IO.Path]::GetTempFileName()
    $statusFile = [System.IO.Path]::GetTempFileName()
    
    # Construct curl data arguments
    $dataArgs = @()
    foreach ($key in $Data.Keys) {
        $dataArgs += "-d"
        $dataArgs += "$key=$($Data[$key])"
    }
    
    try {
        curl.exe -s -X POST $Url @dataArgs -o $tmpFile -w "%{http_code}" | Out-File -FilePath $statusFile -NoNewline
        $status = Get-Content $statusFile
        $body = Get-Content $tmpFile -Raw
        
        if ($status -eq $ExpectedStatus -and $body -match $ExpectedBodyPattern) {
            Write-Host "PASS" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAIL (Status: $status, Body: $body)" -ForegroundColor Red
            return $false
        }
    } finally {
        if (Test-Path $tmpFile) { Remove-Item $tmpFile }
        if (Test-Path $statusFile) { Remove-Item $statusFile }
    }
}

# 1. Menu List
if (Test-Endpoint "Menu List" "$baseUrl/menu" 200 "Menu List") { $score += 10 } else { $failed++ }

# 2. Search
if (Test-Endpoint "Search (Fried)" "$baseUrl/menu?name=Fried" 200 "Fried") { $score += 10 } else { $failed++ }

# 3. Empty Search
if (Test-Endpoint "Empty Search" "$baseUrl/menu?name=NotExist" 200 "(No|not)") { $score += 10 } else { $failed++ }

# 4. Create Order
$orderParams = @{ customer="Alice"; food="Fried Rice"; quantity="2" }
if (Test-PostEndpoint "Create Order" "$baseUrl/order" $orderParams 200 "Order Created") { $score += 10 } else { $failed++ }

# 5. Missing Params
$missingParams = @{ customer="Alice"; food="Fried Rice" }
if (Test-PostEndpoint "Missing Params" "$baseUrl/order" $missingParams 400 "(Error|missing)") { $score += 10 } else { $failed++ }

# 6. Invalid Quantity
$invalidParams = @{ customer="Alice"; food="Burger"; quantity="abc" }
if (Test-PostEndpoint "Invalid Quantity" "$baseUrl/order" $invalidParams 400 "(Error|invalid)") { $score += 10 } else { $failed++ }

# 7. Order Detail
# First create an order to ensure 1001 exists
curl.exe -s -X POST "$baseUrl/order" -d "customer=Bob" -d "food=Burger" -d "quantity=1" > $null
if (Test-Endpoint "Order Detail (1001)" "$baseUrl/order/1001" 200 "Order Detail") { $score += 10 } else { $failed++ }

# 8. Order Not Found
if (Test-Endpoint "Order Not Found (9999)" "$baseUrl/order/9999" 404 "(not|Not|order)") { $score += 10 } else { $failed++ }

# 9. Create then Query
$newOrderParams = @{ customer="Charlie"; food="Noodles"; quantity="3" }
$resBody = curl.exe -s -X POST "$baseUrl/order" -d "customer=Charlie" -d "food=Noodles" -d "quantity=3"
$orderId = ($resBody -split ": ")[1].Trim()
if (Test-Endpoint "Create then Query ($orderId)" "$baseUrl/order/$orderId" 200 "Charlie") { $score += 10 } else { $failed++ }

# 10. HTML Exist
if (Test-Path "src/main/webapp/order.html") {
    Write-Host "Running Test: HTML Exist... PASS" -ForegroundColor Green
    $score += 10
} else {
    Write-Host "Running Test: HTML Exist... FAIL" -ForegroundColor Red
    $failed++
}

Write-Host "================================="
Write-Host "TOTAL SCORE: $score / 100"
Write-Host "================================="

if ($failed -gt 0) { exit 1 }
