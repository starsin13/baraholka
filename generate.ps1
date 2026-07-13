$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$folder = Join-Path $root "tovar1"
$path = Join-Path $root "index.html"

if (!(Test-Path $folder)) {
    Write-Host "ERROR: Folder tovar1 not found"
    exit 1
}

if (!(Test-Path $path)) {
    Write-Host "ERROR: index.html not found"
    exit 1
}

$items = @()

$files = Get-ChildItem $folder -File | Where-Object {
    $_.Extension -match "\.(jpg|jpeg|png|webp)$"
}

Write-Host "Found images: $($files.Count)"

foreach ($file in $files) {

    $id = $file.BaseName
    $txt = Join-Path $folder ($id + ".txt")

    if (!(Test-Path $txt)) {
        @(
            "ID: $id"
            "$id"
            ""
            ""
            "Other"
        ) | Out-File $txt -Encoding UTF8
    }

    $lines = @(Get-Content $txt -Encoding UTF8)

    $title = "No name"
    $price = ""
    $desc = ""
    $category = "Other"

    if ($lines.Count -ge 2) {
        $title = ($lines[1] -replace '^Title:\s*','').Trim()
        if ($title -eq "") {
            $title = "No name"
        }
    }

    if ($lines.Count -ge 3) {
        $price = ($lines[2] -replace '^Price:\s*','').Trim()
    }

    if ($lines.Count -ge 4) {
        $desc = ($lines[3] -replace '^Description:\s*','').Trim()
    }

    if ($lines.Count -ge 5) {
        $category = ($lines[4] -replace '^Category:\s*','').Trim()
        if ($category -eq "") {
            $category = "Other"
        }
    }

    Write-Host "$id -> $title -> $category"

    $items += [PSCustomObject]@{
        img      = "tovar1/$($file.Name)"
        id       = $id
        title    = $title
        price    = $price
        desc     = $desc
        category = $category
    }
}


$json = $items | ConvertTo-Json -Compress -Depth 5

$html = Get-Content $path -Raw -Encoding UTF8

$html = [regex]::Replace(
    $html,
    'const data\s*=\s*\[.*?\];',
    "const data = $json;",
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)

[System.IO.File]::WriteAllText(
    $path,
    $html,
    (New-Object System.Text.UTF8Encoding($false))
)

$json | Set-Content (Join-Path $root "data.json") -Encoding UTF8

Write-Host "DONE! Items: $($items.Count)"
Write-Host ""
Write-Host "DONE! Items: $($items.Count)"
Read-Host "Press Enter to exit"