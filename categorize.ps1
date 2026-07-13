# Auto category fill script
$folder = ".\tovar1"

$rules = @{
    "hdd" = @{ Title = "Hard Disk Drive"; Category = "Electronics" }
    "harddisk" = @{ Title = "Hard Disk Drive"; Category = "Electronics" }
    "ssd" = @{ Title = "SSD Drive"; Category = "Electronics" }
    "router" = @{ Title = "WiFi Router"; Category = "Electronics" }
    "dlink" = @{ Title = "Network Router"; Category = "Electronics" }
    "usb" = @{ Title = "USB Device"; Category = "Electronics" }
    "keyboard" = @{ Title = "Keyboard"; Category = "Electronics" }
    "mouse" = @{ Title = "Computer Mouse"; Category = "Electronics" }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " CATEGORY FILL SCRIPT" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host ""

if (-not (Test-Path $folder)) {
    Write-Host "Folder not found: $folder" -ForegroundColor Red
    exit
}

$images = Get-ChildItem "$folder\*" -File | Where-Object {
    $_.Extension.ToLower() -in ".jpg",".jpeg",".png",".webp"
}

$count = 0

foreach ($img in $images) {
    $filename = $img.BaseName.ToLower()
    
    foreach ($key in $rules.Keys) {
        if ($filename -like "*$key*") {
            $txtFile = Join-Path $img.DirectoryName ($img.BaseName + ".txt")
            
            if (Test-Path $txtFile) {
                # ЧИТАЕМ СУЩЕСТВУЮЩИЙ ФАЙЛ
                $lines = @(Get-Content $txtFile -Encoding UTF8)
                
                # Обновляем ТОЛЬКО Category (строка 5, индекс 4)
                if ($lines.Count -ge 5) {
                    $lines[4] = "$($rules[$key].Category)"   # Меняем только категорию
                    
                    # Сохраняем, не трогая Title, Price и Description
                    $lines | Set-Content $txtFile -Encoding UTF8
                    
                    Write-Host ""
                    Write-Host "$($img.Name)" -ForegroundColor Green
                    Write-Host "  Category обновлена: $($rules[$key].Category)"
                    Write-Host "  Title, Price и Description НЕ тронуты" -ForegroundColor Yellow
                    $count++
                }
                else {
                    Write-Host ""
                    Write-Host "$($img.Name) - неправильная структура файла" -ForegroundColor Red
                }
            }
            else {
                # Создаем новый файл только если его нет
                $newContent = @(
                    "ID: $($img.BaseName)"
                    "$($img.BaseName)"
                    "Price:"
                    "Description:"
                    "$($rules[$key].Category)"
                )
                $newContent | Set-Content $txtFile -Encoding UTF8
                
                Write-Host ""
                Write-Host "$($img.Name) - создан новый txt файл" -ForegroundColor Yellow
                Write-Host "  Category: $($rules[$key].Category)"
                $count++
            }
            break
        }
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "DONE. Updated: $count files" -ForegroundColor Green
Write-Host "========================================"