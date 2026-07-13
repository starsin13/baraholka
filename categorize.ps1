# Auto category and title fill script

$folder = ".\tovar1"


$rules = @{

    "hdd" = @{
        Title = "Hard Disk Drive"
        Category = "Electronics"
    }

    "harddisk" = @{
        Title = "Hard Disk Drive"
        Category = "Electronics"
    }

    "ssd" = @{
        Title = "SSD Drive"
        Category = "Electronics"
    }

    "router" = @{
        Title = "WiFi Router"
        Category = "Electronics"
    }

    "dlink" = @{
        Title = "Network Router"
        Category = "Electronics"
    }

    "usb" = @{
        Title = "USB Device"
        Category = "Electronics"
    }

    "keyboard" = @{
        Title = "Keyboard"
        Category = "Electronics"
    }

    "mouse" = @{
        Title = "Computer Mouse"
        Category = "Electronics"
    }

}



Write-Host "========================================" -ForegroundColor Cyan
Write-Host " CATEGORY FILL SCRIPT" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host ""


if (-not (Test-Path $folder)) {

    Write-Host "Folder not found: $folder" -ForegroundColor Red
    exit

}



$images = Get-ChildItem "$folder\*" -File |
Where-Object {
    $_.Extension.ToLower() -in ".jpg",".jpeg",".png",".webp"
}



$count = 0



foreach ($img in $images) {


    $filename = $img.BaseName.ToLower()


    foreach ($key in $rules.Keys) {


        if ($filename -like "*$key*") {


            $txtFile = Join-Path `
                $img.DirectoryName `
                ($img.BaseName + ".txt")



            if (Test-Path $txtFile) {


                $id = $img.BaseName



                $newContent = @(
                    "ID: $id"
                    "$($rules[$key].Title)"
                    "Price:"
                    "Description:"
                    "$($rules[$key].Category)"
                )



                $newContent | Set-Content `
                    $txtFile `
                    -Encoding UTF8



                Write-Host ""
                Write-Host "$($img.Name)" -ForegroundColor Green
                Write-Host "  Title: $($rules[$key].Title)"
                Write-Host "  Category: $($rules[$key].Category)"


                $count++


            }
            else {

                Write-Host ""
                Write-Host "$($img.Name) - txt not found" -ForegroundColor Yellow

            }


            break

        }

    }

}



Write-Host ""
Write-Host "========================================"
Write-Host "DONE. Updated: $count files" -ForegroundColor Green
Write-Host "========================================"