$ErrorActionPreference = 'Stop'
$BASE_URL = 'http://localhost:8080'
$score = 0
$failed = 0

function Run-Test($scriptName, $scriptBlock) {
    try {
        & $scriptBlock
        Write-Host "PASS: $scriptName"
        $GLOBAL:score += 10
    } catch {
        Write-Host "FAIL: $scriptName - $($_.Exception.Message)"
        $GLOBAL:failed += 1
    }
}

function Get-Http($url) {
    $tmp = [IO.Path]::GetTempFileName()
    try {
        $status = & curl.exe -s -o $tmp -w "%{http_code}" $url
        $body = Get-Content $tmp -Raw
        return @{ Status = $status; Body = $body }
    } finally {
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

Run-Test 'test1_menu' {
    $r = Get-Http "$BASE_URL/menu"
    if ($r.Status -eq '200' -and $r.Body -match 'Menu') { return } else { throw 'menu endpoint not working' }
}

Run-Test 'test2_search' {
    $r = Get-Http "$BASE_URL/menu?name=Fried"
    if ($r.Status -eq '200' -and $r.Body -match 'Fried') { return } else { throw 'search failed' }
}

Run-Test 'test3_empty_search' {
    $r = Get-Http "$BASE_URL/menu?name=NotExistFood"
    if ($r.Status -eq '200' -and ($r.Body -match 'No' -or $r.Body -match 'not')) { return } else { throw 'empty search not handled' }
}

Run-Test 'test4_create_order' {
    $tmp = [IO.Path]::GetTempFileName()
    try {
        $status = & curl.exe -s -o $tmp -w "%{http_code}" -X POST "$BASE_URL/order" -d "customer=Alice" -d "food=Fried Rice" -d "quantity=2"
        $body = Get-Content $tmp -Raw
        if ($status -eq '200' -and $body -match 'Order') { return } else { throw 'order creation failed' }
    } finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
}

Run-Test 'test5_missing_param' {
    $tmp = [IO.Path]::GetTempFileName()
    try {
        $status = & curl.exe -s -o $tmp -w "%{http_code}" -X POST "$BASE_URL/order" -d "customer=Alice" -d "food=Fried Rice"
        $body = Get-Content $tmp -Raw
        if ((($status -eq '200') -or ($status -eq '400')) -and ($body -match 'Error' -or $body -match 'missing') -and ($status -ne '404')) { return } else { throw 'missing parameter not handled' }
    } finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
}

Run-Test 'test6_invalid_quantity' {
    $tmp = [IO.Path]::GetTempFileName()
    try {
        $status = & curl.exe -s -o $tmp -w "%{http_code}" -X POST "$BASE_URL/order" -d "customer=Alice" -d "food=Burger" -d "quantity=abc"
        $body = Get-Content $tmp -Raw
        if ((( $status -eq '200') -or ($status -eq '400')) -and ($body -match 'Error' -or $body -match 'invalid') -and ($status -ne '404')) { return } else { throw 'invalid quantity not handled' }
    } finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
}

Run-Test 'test7_order_detail' {
    # create order
    & curl.exe -s -X POST "$BASE_URL/order" -d "customer=Bob" -d "food=Burger" -d "quantity=1" | Out-Null
    $r = Get-Http "$BASE_URL/order/1001"
    if ($r.Status -eq '200' -and $r.Body -match 'Order') { return } else { throw 'order detail not working' }
}

Run-Test 'test8_order_not_found' {
    $r = Get-Http "$BASE_URL/order/9999"
    if ($r.Status -eq '404' -or ((($r.Status -eq '200') -or ($r.Status -eq '400')) -and ($r.Body -match 'Error' -or $r.Body -match 'not' -or $r.Body -match 'Not') -and ($r.Body -match 'order' -or $r.Body -match 'Order'))) { return } else { throw 'missing order not handled' }
}

Run-Test 'test9_create_then_query' {
    & curl.exe -s -X POST "$BASE_URL/order" -d "customer=Charlie" -d "food=Noodles" -d "quantity=3" | Out-Null
    $r = Get-Http "$BASE_URL/order/1002"
    if ($r.Status -eq '200' -and $r.Body -match 'Charlie') { return } else { throw 'create then query failed' }
}

Run-Test 'test10_html_exist' {
    if (Test-Path -Path 'src/main/webapp/order.html') { return } else { throw 'html page missing' }
}

Write-Host '================================='
Write-Host "TOTAL SCORE: $score / 100"
Write-Host '================================='

if ($failed -ne 0) { exit 1 } else { exit 0 }
