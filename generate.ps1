$folder = "tovar1"

if (!(Test-Path $folder)) { mkdir $folder }

Get-ChildItem -Path $folder -Filter "*.jpg" | ForEach-Object {
    $txtPath = "$folder\$($_.BaseName).txt"
    if (!(Test-Path $txtPath)) {
        "Title`nPrice`nDescription" | Out-File -FilePath $txtPath -Encoding UTF8
        Write-Host "Created: $txtPath"
    }
}

$items = @()
Get-ChildItem -Path $folder -Filter "*.jpg" | ForEach-Object {
    $name = $_.BaseName
    $txtPath = "$folder\$name.txt"
    
    $title = $name
    $price = ""
    $desc = ""
    
    if (Test-Path $txtPath) {
        $lines = Get-Content -Path $txtPath -Encoding UTF8 -Raw
        $lines = $lines -split "`r`n|`n"
        if ($lines.Count -gt 0) { $title = $lines[0].Trim() }
        if ($lines.Count -gt 1) { $price = $lines[1].Trim() }
        if ($lines.Count -gt 2) { $desc = $lines[2].Trim() }
    }
    
    $item = @{
        img = "$folder/$($_.Name)"
        title = $title
        price = $price
        desc = $desc
    }
    $items += $item
}

$items | ConvertTo-Json -Compress | Set-Content -Path "items.json" -Encoding UTF8

Write-Host "Found $($items.Count) photos"