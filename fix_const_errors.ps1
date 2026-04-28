$featuresPath = 'lib\features'

Get-ChildItem -Path $featuresPath -Recurse -Filter '*.dart' | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -Encoding UTF8
    $original = $content

    # ─── Fix 1: Remove 'const' before TextStyle(color: context.qsColors...)
    $content = $content -replace 'const (TextStyle\([^)]*context\.qsColors[^)]*\))', '$1'

    # ─── Fix 2: Remove 'const' before Icon(..., color: context.qsColors...)
    $content = $content -replace 'const (Icon\([^)]*context\.qsColors[^)]*\))', '$1'

    # ─── Fix 3: Remove 'const' before CircularProgressIndicator(color: context.qsColors...)
    $content = $content -replace 'const (CircularProgressIndicator\([^)]*context\.qsColors[^)]*\))', '$1'

    # ─── Fix 4: Replace Color[] operator - textSub[900] -> textSub
    $content = $content -replace 'context\.qsColors\.textSub\[\d+\]!?', 'context.qsColors.textSub'

    # ─── Fix 5: Replace Color[] operator - info[50] -> info.withValues(alpha: 0.05)
    $content = $content -replace 'context\.qsColors\.info\[50\]!?', 'context.qsColors.info.withValues(alpha: 0.05)'
    $content = $content -replace 'context\.qsColors\.info\[\d+\]!?', 'context.qsColors.info'

    # ─── Fix 6: infoGrey doesn't exist -> textSub
    $content = $content -replace 'context\.qsColors\.infoGrey(\[\d+\])?', 'context.qsColors.textSub'

    # ─── Fix 7: card70 doesn't exist -> card.withValues(alpha: 0.7)
    $content = $content -replace 'context\.qsColors\.card70', 'context.qsColors.card.withValues(alpha: 0.7)'

    if ($content -ne $original) {
        Set-Content $_.FullName $content -Encoding UTF8
        Write-Host "Fixed: $($_.Name)"
    }
}
Write-Host "Done!"
