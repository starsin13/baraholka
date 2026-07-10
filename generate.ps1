$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$folder = Join-Path $root "tovar1"
$path = Join-Path $root "index.html"

if (!(Test-Path $folder)) {
    Write-Host "ERROR: Folder tovar1 not found"
    Read-Host "Press Enter"
    exit 1
}

if (!(Test-Path $path)) {
    Write-Host "ERROR: index.html not found"
    Read-Host "Press Enter"
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
        Write-Host "  Created template: $($file.Name) -> $($id).txt"
        @(
            "ID: $id",
            "Title: ",
            "Price: ",
            "Description: ",
            "Category: "
        ) | Out-File $txt -Encoding UTF8
    }

    $lines = @(Get-Content $txt -Encoding UTF8)
    
    $title = "No name"
    $price = "0"
    $desc = "No description"
    $category = "Other"

    if ($lines.Count -ge 2) { 
        $title = ($lines[1] -replace '^Title:\s*', '').Trim()
        if ($title -eq '') { $title = "No name" }
    }
    if ($lines.Count -ge 3) { 
        $price = ($lines[2] -replace '^Price:\s*', '').Trim()
        if ($price -eq '') { $price = "0" }
    }
    if ($lines.Count -ge 4) { 
        $desc = ($lines[3] -replace '^Description:\s*', '').Trim()
        if ($desc -eq '') { $desc = "No description" }
    }
    if ($lines.Count -ge 5) { 
        $category = ($lines[4] -replace '^Category:\s*', '').Trim()
        if ($category -eq '') { $category = "Other" }
    }

    Write-Host "  $($id) -> Category: $category"

    $items += [PSCustomObject]@{
        img      = "tovar1/$($file.Name)"
        id       = $id
        title    = $title
        price    = $price
        desc     = $desc
        category = $category
    }
}

if ($items.Count -eq 0) {
    Write-Host "ERROR: No images found in tovar1 folder"
    Read-Host "Press Enter"
    exit 1
}

$json = $items | ConvertTo-Json -Compress -Depth 5

$html = Get-Content $path -Raw -Encoding UTF8

if ($html -match 'const data = \[.*?\];') {
    $html = [regex]::Replace(
        $html,
        'const data = \[.*?\];',
        "const data = $json;",
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    Write-Host "Data updated in index.html"
} else {
    Write-Host "WARNING: 'const data = [...]' not found in index.html"
    Write-Host "Add this line manually: const data = []; // will be replaced"
}

[System.IO.File]::WriteAllText($path, $html, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "DONE! Items: $($items.Count)"
Read-Host "Press Enter to exit"