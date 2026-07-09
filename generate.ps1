$folder = "tovar1"

# Find images
$images = Get-ChildItem -Path $folder -File | Where-Object {
    $_.Extension.ToLower() -in @(".jpg", ".jpeg")
} | Sort-Object Name


# Create txt for new images
foreach ($img in $images) {

    $txtPath = Join-Path $folder ($img.BaseName + ".txt")

    if (!(Test-Path $txtPath)) {

        $content = @(
            $img.BaseName
            "Product name"
            "Price"
            "Description"
        )

        Set-Content -Path $txtPath -Value $content -Encoding UTF8

        Write-Host "Created: $txtPath"
    }
}


# Build items
$items = @()

foreach ($img in $images) {

    $txtPath = Join-Path $folder ($img.BaseName + ".txt")

    $id = [string]$img.BaseName
    $title = "Product name"
    $price = "Price"
    $desc = "Description"


    if (Test-Path $txtPath) {

        $lines = @(Get-Content -Path $txtPath -Encoding UTF8 | ForEach-Object {
            [string]$_
        })


        if ($lines.Count -ge 1) {
            $id = [string]$lines[0]
        }

        if ($lines.Count -ge 2) {
            $title = [string]$lines[1]
        }

        if ($lines.Count -ge 3) {
            $price = [string]$lines[2]
        }

        if ($lines.Count -ge 4) {

            $desc = ($lines | Select-Object -Skip 3) -join "<br>"
        }
    }


    $items += [PSCustomObject]@{
        img = "$folder/$($img.Name)"
        id = $id
        title = $title
        price = $price
        desc = $desc
    }
}


# Convert to JSON
$json = $items | ConvertTo-Json -Compress


# Update index.html
$html = Get-Content -Path index.html -Raw -Encoding UTF8

$pattern = 'const data = \[.*?\];'

$newHtml = [regex]::Replace(
    $html,
    $pattern,
    "const data = $json;",
    "Singleline"
)


# Save index.html
Set-Content -Path index.html -Value $newHtml -Encoding UTF8


Write-Host ""
Write-Host "Updated! Found $($items.Count) image(s)."