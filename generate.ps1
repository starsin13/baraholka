$folder = "tovar1"

# Создаём txt для каждого jpg, если его нет
Get-ChildItem -Path $folder -Filter "*.jpg" | ForEach-Object {
    $txtPath = "$folder\$($_.BaseName).txt"
    if (!(Test-Path $txtPath)) {
        "Title`nPrice`nDescription" | Out-File -FilePath $txtPath -Encoding UTF8
        Write-Host "Created: $txtPath"
    }
}

# Читаем фото и txt
$items = @()
Get-ChildItem -Path $folder -Filter "*.jpg" | ForEach-Object {
    $name = $_.BaseName
    $txtPath = "$folder\$name.txt"
    
    $title = $name
    $price = ""
    $desc = ""
    
    if (Test-Path $txtPath) {
        $lines = Get-Content -Path $txtPath -Encoding UTF8
        if ($lines.Count -gt 0) { $title = $lines[0] }
        if ($lines.Count -gt 1) { $price = $lines[1] }
        if ($lines.Count -gt 2) { $desc = $lines[2] }
    }
    
    $items += @{
        img = "$folder/$($_.Name)"
        title = $title
        price = $price
        desc = $desc
    }
}

# Преобразуем в JSON
$json = $items | ConvertTo-Json -Compress

# Читаем index.html
$html = Get-Content -Path index.html -Raw

# Заменяем массив data
$pattern = 'const data = \[.*?\];'
$newData = "const data = $json;"
$newHtml = $html -replace $pattern, $newData

# Сохраняем
$newHtml | Set-Content -Path index.html -Encoding UTF8

Write-Host "✅ Updated! Found $($items.Count) items"