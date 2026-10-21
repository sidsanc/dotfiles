<#
.SYNOPSIS
  Set up this machine's PowerShell + oh-my-posh from the dotfiles repo.

.DESCRIPTION
  - Installs oh-my-posh, a Nerd Font and Terminal-Icons (skips what is present).
  - Points BOTH the PowerShell 7 and Windows PowerShell 5.1 profiles at
    powershell\profile.ps1 in this repo (a one-line stub; existing profiles are backed up).
  - With -WithAppSettings, also copies Windows Terminal and Cursor settings
    (existing files are backed up first).

  Re-runnable. Safe to run from any clone location.
#>
[CmdletBinding()]
param(
    [switch]$WithAppSettings
)

$ErrorActionPreference = 'Stop'
$repo  = $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Backup-IfExists([string]$Path) {
    if (Test-Path $Path) {
        Copy-Item $Path "$Path.$stamp.bak"
        Write-Host "  backed up -> $Path.$stamp.bak"
    }
}

# --- 1. prerequisites -------------------------------------------------------
Write-Host '== Prerequisites'
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    winget install --id JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
    Write-Host '  oh-my-posh installed (open a NEW terminal so it is on PATH)'
} else { Write-Host '  oh-my-posh present' }

$fontInstalled = [bool](
    'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts',
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' |
        ForEach-Object { (Get-ItemProperty $_ -ErrorAction SilentlyContinue).PSObject.Properties } |
        Where-Object Name -Like 'CaskaydiaCove NF*' |
        Select-Object -First 1)
if (-not $fontInstalled) {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) { oh-my-posh font install CascadiaCode }
    else { Write-Warning 'Re-run after opening a new terminal to install the font (oh-my-posh not on PATH yet).' }
} else { Write-Host '  CaskaydiaCove Nerd Font present' }

if (-not (Get-Module -ListAvailable Terminal-Icons)) {
    Install-Module Terminal-Icons -Scope CurrentUser -Force
} else { Write-Host '  Terminal-Icons present' }

# --- 2. profile stubs -------------------------------------------------------
Write-Host '== Profiles'
# The stub is machine-independent ($HOME-relative) on purpose: Documents may be synced
# by OneDrive, so an absolute path from one PC would break another.
if ($repo -ne (Join-Path $HOME 'dotfiles')) {
    Write-Warning "Repo is at $repo but the profile stub expects $HOME\dotfiles. Clone/move it there."
}
$stub = @'
# Managed by dotfiles (~\dotfiles). Edit powershell\profile.ps1 there, not here.
$dotProfile = Join-Path $HOME 'dotfiles\powershell\profile.ps1'
if (Test-Path $dotProfile) { . $dotProfile } else { Write-Warning "dotfiles profile not found: $dotProfile" }
'@
$docs = [Environment]::GetFolderPath('MyDocuments')
foreach ($dir in 'PowerShell', 'WindowsPowerShell') {
    $target = Join-Path $docs "$dir\Microsoft.PowerShell_profile.ps1"
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
    if ((Test-Path $target) -and ((Get-Content $target -Raw).TrimEnd() -eq $stub.TrimEnd())) { Write-Host "  $target already up to date"; continue }
    Backup-IfExists $target
    Set-Content -Path $target -Value $stub -Encoding UTF8
    Write-Host "  wrote $target"
}

# --- 3. app settings (opt-in) ----------------------------------------------
if ($WithAppSettings) {
    Write-Host '== App settings'
    $wt = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    if (Test-Path (Split-Path $wt)) {
        Backup-IfExists $wt
        Copy-Item (Join-Path $repo 'windows-terminal\settings.json') $wt -Force
        Write-Host '  Windows Terminal settings installed'
    } else { Write-Warning 'Windows Terminal not found; skipped.' }

    $cursor = Join-Path $env:APPDATA 'Cursor\User\settings.json'
    New-Item -ItemType Directory -Force (Split-Path $cursor) | Out-Null
    Backup-IfExists $cursor
    Copy-Item (Join-Path $repo 'cursor\settings.json') $cursor -Force
    Write-Host '  Cursor settings installed (check python.defaultInterpreterPath for this machine)'
}

Write-Host "`nDone. Open a new terminal." -ForegroundColor Green
