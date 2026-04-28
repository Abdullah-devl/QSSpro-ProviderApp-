# Fix remaining const errors with multiline patterns
$featuresPath = 'lib\features'

Get-ChildItem -Path $featuresPath -Recurse -Filter '*.dart' | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -Encoding UTF8
    $original = $content

    # Remove const from ANY widget constructor that contains context.qsColors
    # This handles cases where const appears before a widget on a different line
    # Pattern: const SomeWidget( ... context.qsColors ... )
    
    # Fix: backgroundColor: context.qsColors.X in const contexts (already handled by previous script for single-liners)
    # Fix remaining: color: context.qsColors in const TextStyle / Icon that are still const
    
    # Broad approach: find 'const' followed on same line by any reference to context.qsColors
    $content = $content -replace 'const ((?:TextStyle|Icon|CircularProgressIndicator|Text)\([^)]*context\.qsColors[^)]*\))', '$1'
    
    # Also fix backgroundColor: context.qsColors.X where this causes a const parent to fail
    # (These are caught by the Flutter compiler, not easily regex-fixable without AST)
    
    if ($content -ne $original) {
        Set-Content $_.FullName $content -Encoding UTF8
        Write-Host "Fixed: $($_.Name)"
    }
}
Write-Host "Done!"
