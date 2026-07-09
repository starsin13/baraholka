$folder = "tovar1"

# Получаем все изображения (.jpg/.jpeg в любом регистре)
$images = Get-ChildItem -Path $folder -File | Where-Object {
    $_.Extension.ToLower() -in @(".jpg", ".jpeg")
} | Sort-Object Name

# Создаём txt для новых изображений
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


# Создаём список товаров
$items = @()

foreach ($img in $images) {

    $txtPath = Join-Path $folder ($img.BaseName + ".txt")

    $title = $img.BaseName
    $price = ""
    $desc = ""

    if (Test-Path $txtPath) {

        # Читаем строки и убираем пробелы/табы
        $lines = @(Get-Content $txtPath -Encoding UTF8 | ForEach-Object {
            $_.Trim()
        })

        if ($lines.Count -ge 1 -and $lines[0] -ne "") {
            $title = $lines[0]
        }

        if ($lines.Count -ge 2 -and $lines[1] -ne "") {
            $price = $lines[1]
        }

        if ($lines.Count -gt 2) {

            $descLines = $lines | Select-Object -Skip 2 | Where-Object {
                $_ -ne ""
            }

            $desc = $descLines -join "<br>"
        }
    }

    $items += [PSCustomObject]@{
        img   = "$folder/$($img.Name)"
        title = $title
        price = $price
        desc  = $desc
    }
}


# JSON
$json = $items | ConvertTo-Json -Compress


# Обновляем index.html
$html = Get-Content -Path index.html -Raw

$pattern = 'const data = \[.*?\];'

$newData = "const data = $json;"

$newHtml = [regex]::Replace(
    $html,
    $pattern,
    $newData,
    "Singleline"
)


# Сохраняем
$newHtml | Set-Content -Path index.html -Encoding UTF8


Write-Host ""
Write-Host "Updated! Found $($items.Count) image(s)."