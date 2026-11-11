[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$project = 'office-6128a'
$target = 'epart'
$site = 'bytes-epart-tools'
Get-Command firebase -ErrorAction Stop | Out-Null

$stage = Join-Path ([IO.Path]::GetTempPath()) ('epart-hosting-' + [guid]::NewGuid())
$public = Join-Path $stage 'public'
$docs = Join-Path $public 'docs'
New-Item -ItemType Directory -Path $docs | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'index.html') -Destination $public
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'docs/specification.html') -Destination $docs

@{ hosting = @{ target = $target; public = 'public' } } |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $stage 'firebase.json') -Encoding ascii
@{ targets = @{ $project = @{ hosting = @{ $target = @($site) } } } } |
    ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $stage '.firebaserc') -Encoding ascii

Push-Location -LiteralPath $stage
try {
    firebase deploy --only "hosting:$target" --project $project --non-interactive
    if ($LASTEXITCODE -ne 0) {
        throw "Firebase Hosting deployment failed (exit $LASTEXITCODE)."
    }
}
finally {
    Pop-Location
}
