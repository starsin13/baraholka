$folder = "tovar1"

# Получаем все изображения (.jpg/.jpeg в любом регистре)
$images = Get-ChildItem -Path $folder -File | Where-Object {
    $_.Extension.ToLower() -in @(".jpg", ".jpeg")
} | Sort-Object Name

# Создаём txt для каждого изображения, если его нет
foreach ($img in $images) {
    $txtPath = Join-Path $folder ($img.BaseName + ".txt")

    if (!(Test-Path $txtPath)) {
        @"
Title
Price
Description
"@ | Set-Content -Path $txtPath -Encoding UTF8

        Write-Host "Created: $txtPath"
    }
}

# Формируем список товаров
$items = @()

foreach ($img in $images) {

    $txtPath = Join-Path $folder ($img.BaseName + ".txt")

    $title = $img.BaseName
    $price = ""
    $desc = ""

    if (Test-Path $txtPath) {

        $lines = Get-Content $txtPath -Encoding UTF8

        if ($lines.Count -ge 1) { $title = $lines[0] }
        if ($lines.Count -ge 2) { $price = $lines[1] }

        # Всё после первых двух строк становится описанием
        if ($lines.Count -gt 2) {
            $desc = ($lines | Select-Object -Skip 2) -join "<br>"
        }
    }

    $items += @{
        img   = "$folder/$($img.Name)"
        title = $title
        price = $price
        desc  = $desc
    }
}

# Преобразуем в JSON
$json = $items | ConvertTo-Json -Compress

# Читаем index.html
$html = Get-Content -Path index.html -Raw

# Заменяем массив data
$pattern = 'const data = \[.*?\];'
$newData = "const data = $json;"

$newHtml = [regex]::Replace($html, $pattern, $newData, "Singleline")

# Сохраняем
$newHtml | Set-Content -Path index.html -Encoding UTF8

Write-Host ""
Write-Host "✅ Updated! Found $($items.Count) image(s)."