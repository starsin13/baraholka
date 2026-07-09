$folder = "tovar1"

$images = Get-ChildItem -Path $folder -File | Where-Object {
    $_.Extension.ToLower() -in @(".jpg", ".jpeg")
} | Sort-Object Name


# Создание txt для новых картинок
foreach ($img in $images) {

    $txtPath = Join-Path $folder ($img.BaseName + ".txt")

    if (!(Test-Path $txtPath)) {

        @"
$($img.BaseName)
Название товара
Цена
Описание
"@ | Set-Content -Path $txtPath -Encoding UTF8

        Write-Host "Created: $txtPath"
    }
}


$items = @()

foreach ($img in $images) {

    $txtPath = Join-Path $folder ($img.BaseName + ".txt")

    $id = $img.BaseName
    $title = $img.BaseName
    $price = ""
    $desc = ""

    if (Test-Path $txtPath) {

        $lines = @(Get-Content $txtPath -Encoding UTF8 | ForEach-Object {
            $_.Trim()
        })

        if ($lines.Count -ge 1) { $id = $lines[0] }
        if ($lines.Count -ge 2) { $title = $lines[1] }
        if ($lines.Count -ge 3) { $price = $lines[2] }

        if ($lines.Count -gt 3) {

            $descLines = $lines | Select-Object -Skip 3 | Where-Object {
                $_ -ne ""
            }

            $desc = $descLines -join "<br>"
        }
    }


    $items += [PSCustomObject]@{
        img   = "$folder/$($img.Name)"
        id    = $id
        title = $title
        price = $price
        desc  = $desc
    }
}


$json = $items | ConvertTo-Json -Compress


$html = Get-Content -Path index.html -Raw

$pattern = 'const data = \[.*?\];'

$newData = "const data = $json;"

$newHtml = [regex]::Replace(
    $html,
    $pattern,
    $newData,
    "Singleline"
)

$newHtml | Set-Content -Path index.html -Encoding UTF8


Write-Host ""
Write-Host "Updated! Found $($items.Count) image(s)."