[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$Message = 'Update Bytes EPART DSL',
    [ValidatePattern('^v\d+\.\d+(\.\d+)?(-[A-Za-z0-9][A-Za-z0-9.-]*)?$')]
    [string]$Tag,
    [string]$NotesFile
)

$ErrorActionPreference = 'Stop'
$repo = 'RyanHsu255/bytes-epart-dsl'
$remote = "https://github.com/$repo.git"
$publicFiles = @(
    'README.md'
    'AGENTS.md'
    'AGENTS_TC.md'
    'Publish-GitHub.bat'
    'Publish-GitHub.ps1'
    'Deploy-Firebase.bat'
    'Deploy-Firebase.ps1'
    'CHANGELOG.md'
    'index.html'
    'docs/designation-symbols.md'
    'docs/specification.html'
    'docs/specification.md'
)

function Invoke-Checked {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Program $($Arguments[0]) failed (exit $LASTEXITCODE)."
    }
}

Get-Command git -ErrorAction Stop | Out-Null
if ($Tag) {
    if (!$NotesFile) { throw 'Provide -NotesFile when creating a release.' }
    $NotesFile = (Resolve-Path -LiteralPath $NotesFile).ProviderPath
    Get-Command gh -ErrorAction Stop | Out-Null
    Invoke-Checked gh @('auth', 'status', '--hostname', 'github.com')
}

$work = Join-Path ([IO.Path]::GetTempPath()) ('epart-publish-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $work | Out-Null
$checkout = Join-Path $work 'repo'
Invoke-Checked git @('clone', $remote, $checkout)
Push-Location -LiteralPath $checkout
try {
    foreach ($file in $publicFiles) {
        $destination = Join-Path $checkout $file
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination $destination
    }
    # The source CAD files stay in the local project.
    $specification = Join-Path $checkout 'docs/specification.md'
    $markdown = [IO.File]::ReadAllText($specification)
    $markdown = $markdown -replace '\[([^\]]+)\]\(\.\./refs/[^)]+\)', '$1'
    [IO.File]::WriteAllText($specification, $markdown)

    Invoke-Checked git (@('add', '--') + $publicFiles)
    $changes = Invoke-Checked git @('diff', '--cached', '--name-only')
    if ($changes) {
        Invoke-Checked git @('commit', '-m', $Message)
        $branch = Invoke-Checked git @('branch', '--show-current')
        Invoke-Checked git @('push', 'origin', "HEAD:refs/heads/$branch")
    }
    if ($Tag) {
        $commit = Invoke-Checked git @('rev-parse', 'HEAD')
        $asset = Join-Path $work "Bytes-EPART-DSL-$Tag.zip"
        Invoke-Checked git (@('archive', '--format=zip', "--output=$asset", $commit, '--') + $publicFiles)
        $releaseArgs = @('release', 'create', $Tag, $asset, '--repo', $repo, '--target', $commit,
            '--title', "Bytes EPART DSL $Tag", '--notes-file', $NotesFile)
        if ($Tag.Contains('-')) { $releaseArgs += '--prerelease' }
        Invoke-Checked gh $releaseArgs
    }
}
finally {
    Pop-Location
    Write-Host "Working copy and release archive (if generated): $work"
}
