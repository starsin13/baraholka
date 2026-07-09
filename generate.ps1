$path = "C:\baraholka\index.html"
$folder = "C:\baraholka\tovar1"


if (!(Test-Path $path)) {
    Write-Host "ERROR: index.html not found"
    exit 1
}

if (!(Test-Path $folder)) {
    Write-Host "ERROR: tovar1 folder not found"
    exit 1
}


$items = @()


Get-ChildItem $folder -File | Where-Object {
    $_.Extension -match "\.(jpg|jpeg|png|webp|gif)$"
} | ForEach-Object {

    $file = $_
    $id = [string]$file.BaseName

    $title = "Product name"
    $price = "Price"
    $desc = "Description"


    $txt = Join-Path $folder ($id + ".txt")


    if (Test-Path $txt) {

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
    }


    $items += [PSCustomObject]@{
        img   = [string]"tovar1/$($file.Name)"
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


# Создаем JSON-массив для PowerShell 5.1
$jsonParts = @()

foreach ($item in $items) {
    $jsonParts += ($item | ConvertTo-Json -Compress)
}

$json = "[" + ($jsonParts -join ",") + "]"


$html = Get-Content $path -Raw -Encoding UTF8


# Ищем блок const data = [...]
$pattern = '(?s)const data\s*=\s*\[.*?\];'


if ($html -notmatch $pattern) {
    Write-Host "ERROR: DATA block not found"
    exit 1
}


$newBlock = "const data = $json;"


$html = [regex]::Replace(
    $html,
    $pattern,
    $newBlock
)


[System.IO.File]::WriteAllText(
    $path,
    $html,
    (New-Object System.Text.UTF8Encoding($false))
)


Write-Host "Gallery generated. Items: $($items.Count)"