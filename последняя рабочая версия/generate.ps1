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

foreach ($file in $files) {

    $id = $file.BaseName

    $title = "Product name"
    $price = "Price"
    $desc = "Description"

    $txt = Join-Path $folder ($id + ".txt")

    # Создаем txt-шаблон, если его нет
    if (!(Test-Path $txt)) {
        @(
            $id
            "Product name"
            "Price"
            "Description"
        ) | Out-File $txt -Encoding UTF8
    }

    # Читаем описание из txt
    $lines = @(Get-Content $txt -Encoding UTF8)

    if ($lines.Count -ge 2) {
        $title = [string]$lines[1]
    }

    if ($lines.Count -ge 3) {
        $price = [string]$lines[2]
    }

    if ($lines.Count -ge 4) {
        $desc = [string]$lines[3]
    }

    $items += [PSCustomObject]@{
        img   = "tovar1/$($file.Name)"
        id    = $id
        title = $title
        price = $price
        desc  = $desc
    }
}

if ($items.Count -eq 0) {
    Write-Host "ERROR: No images found"
    exit 1
}

$json = $items | ConvertTo-Json -Compress -Depth 5

$html = Get-Content $path -Raw -Encoding UTF8

# Правильная замена массива данных в index.html
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

Write-Host "Gallery generated. Items: $($items.Count)"