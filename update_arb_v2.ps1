$jsonBlock = @'
  "actionCopy": "Copy",
  "actionShare": "Share",
  "amountLabel": "Amount"
}
'@

$path = "lib/l10n"
$files = Get-ChildItem "$path/app_*.arb" | Where-Object { $_.Name -ne "app_es.arb" -and $_.Name -ne "app_en.arb" }

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $content = $content.TrimEnd().TrimEnd('}')
        if (-not $content.TrimEnd().EndsWith(",")) {
            $content += ","
        }
        $newContent = $content + "`n" + $jsonBlock
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        Write-Host "Updated $($file.Name)"
    } catch {
        Write-Error "Error updating $($file.Name): $_"
    }
}
