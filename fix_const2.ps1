# Fix: Remove 'const' from any parent widget constructor that has 'context.qsColors' in its content
# This fixes cases like: icon: const Icon(Icons.add, color: context.qsColors.card)
# where the const was already removed from Icon() but not from the outer widget

$featuresPath = 'lib\features'

Get-ChildItem -Path $featuresPath -Recurse -Filter '*.dart' | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -Encoding UTF8
    $original = $content

    # Fix multiline const expressions: const Widget(\n  ...\n  context.qsColors...)
    # This is hard to do with regex, so we'll do specific fixes:

    # 1. Scaffold( backgroundColor: context.qsColors.X ) - remove const from Scaffold
    # Not needed, Scaffold is never const

    # 2. Style: const TextStyle( ...multiline... context.qsColors)
    # These should already be fixed by previous script for single-line
    
    # Fix: any 'const' directly before specific widgets that can't be const due to context
    $content = $content -replace 'const (ElevatedButton\.[^(]+\([^)]*context\.qsColors[^)]*\))', '$1'
    $content = $content -replace 'const (OutlinedButton\.[^(]+\([^)]*context\.qsColors[^)]*\))', '$1'
    
    # Fix specific pattern: icon: const Icon(X, color: context.qsColors.Y),
    $content = $content -replace 'icon: const (Icon\([^)]*context\.qsColors[^)]*\))', 'icon: $1'
    
    # Fix: leading: IconButton(icon: const Icon(X, color: context.qsColors.Y)
    $content = $content -replace '(IconButton\(icon: )const (Icon\([^)]*context\.qsColors[^)]*\))', '$1$2'
    
    if ($content -ne $original) {
        Set-Content $_.FullName $content -Encoding UTF8
        Write-Host "Fixed: $($_.Name)"
    }
}
Write-Host "Done!"
