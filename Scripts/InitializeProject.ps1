<#
.SYNOPSIS
    Rename this Godot .NET starter template to a new project name.

.DESCRIPTION
    This script renames directories under Sources that contain the hardcoded old name
    "StarterTemplate" and updates the Godot project file and solution references.

    It also renames any .csproj files that contain "StarterTemplate" in their name,
    and updates internal references inside project.godot, .sln, and .csproj files.

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Scripts\InitializeProject.ps1

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Scripts\InitializeProject.ps1 -Name "MyGame"
#>

[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Name
)

$oldName = 'StarterTemplate'

function Get-ProjectRoot {
    if ($PSScriptRoot) {
        return Split-Path -Parent $PSScriptRoot
    }

    if ($MyInvocation.MyCommand.Path) {
        return Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
    }

    $currentPath = (Get-Location).ProviderPath
    if ($currentPath) {
        $currentLeaf = Split-Path -Leaf $currentPath
        if ($currentLeaf -ieq 'Scripts') {
            $candidate = Split-Path -Parent $currentPath
            if (Test-Path (Join-Path $candidate 'Sources')) {
                return $candidate
            }
        }

        if (Test-Path (Join-Path $currentPath 'Sources')) {
            return $currentPath
        }
    }

    return $currentPath
}

function Validate-ProjectName {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw 'Project name is required and cannot be empty.'
    }

    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    if ($Value.ToCharArray() | Where-Object { $invalidChars -contains $_ }) {
        throw "Project name '$Value' contains invalid file name characters."
    }

    if ($Value -eq $oldName) {
        throw "Project name must be different from '$oldName'."
    }
}

if ([string]::IsNullOrWhiteSpace($Name)) {
    $Name = Read-Host 'Enter new project name'
}

try {
    Validate-ProjectName -Value $Name
} catch {
    Write-Error $_
    exit 1
}

$root = Get-ProjectRoot
$sourceRoot = Join-Path $root 'Sources'
if (-not (Test-Path $sourceRoot)) {
    Write-Error "ERROR: Could not find Sources folder at '$sourceRoot'."
    exit 1
}

Write-Output "Renaming project from '$oldName' to '$Name'..."

# Rename .csproj files whose names contain the old name.
$csprojFiles = Get-ChildItem -Path $sourceRoot -Filter '*.csproj' -Recurse
foreach ($file in $csprojFiles) {
    if ($file.Name.Contains($oldName)) {
        $newFileName = $file.Name.Replace($oldName, $Name)
        $newPath = Join-Path $file.DirectoryName $newFileName
        Write-Output "Renaming .csproj:`n  $($file.FullName)`n  -> $newPath"
        Move-Item -LiteralPath $file.FullName -Destination $newPath
    }
}

# Rename any directories under Sources that contain the old name.
$dirs = Get-ChildItem -Path $sourceRoot -Directory -Recurse | Where-Object { $_.Name.Contains($oldName) }
$dirs = $dirs | Sort-Object { $_.FullName.Length } -Descending
foreach ($dir in $dirs) {
    $newDirName = $dir.Name.Replace($oldName, $Name)
    if ($newDirName -ne $dir.Name) {
        $newPath = Join-Path $dir.Parent.FullName $newDirName
        Write-Output "Renaming directory:`n  $($dir.FullName)`n  -> $newPath"
        if (Test-Path $newPath) {
            Write-Warning "Target directory already exists: $newPath. Skipping rename of $($dir.FullName)."
        } else {
            Move-Item -LiteralPath $dir.FullName -Destination $newPath
        }
    }
}

# Update project.godot and any other Godot config files inside Sources.
$godotFiles = Get-ChildItem -Path $sourceRoot -Filter 'project.godot' -Recurse
foreach ($file in $godotFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    if ($text.Contains($oldName)) {
        $updated = $text.Replace($oldName, $Name)
        Set-Content -LiteralPath $file.FullName -Value $updated -Encoding utf8
        Write-Output "Updated Godot project file: $($file.FullName)"
    }
}

# Update .sln file references.
$slnPath = Join-Path $root "$oldName.sln"
if (Test-Path $slnPath) {
    $slnText = Get-Content -LiteralPath $slnPath -Raw
    if ($slnText.Contains($oldName)) {
        $updatedSln = $slnText.Replace($oldName, $Name)
        Set-Content -LiteralPath $slnPath -Value $updatedSln -Encoding utf8
        Write-Output "Updated solution file references: $slnPath"
    }

    $newSlnPath = Join-Path $root "$Name.sln"
    if ($newSlnPath -ne $slnPath) {
        Write-Output "Renaming solution file:`n  $slnPath`n  -> $newSlnPath"
        Move-Item -LiteralPath $slnPath -Destination $newSlnPath -Force
    }

    if (Test-Path $slnPath) {
        Remove-Item -LiteralPath $slnPath -Force
        Write-Output "Removed old solution file: $slnPath"
    }
    if (Test-Path $newSlnPath) {
        Write-Output "Verified new solution file: $newSlnPath"
    }
} else {
    Write-Warning "Solution file '$slnPath' was not found. Skipping .sln updates."
}

# Update internal references in remaining .csproj files.
$csprojFiles = Get-ChildItem -Path $sourceRoot -Filter '*.csproj' -Recurse
foreach ($file in $csprojFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    if ($text.Contains($oldName)) {
        $updated = $text.Replace($oldName, $Name)
        Set-Content -LiteralPath $file.FullName -Value $updated -Encoding utf8
        Write-Output "Updated .csproj references: $($file.FullName)"
    }
}

# Replace root README with a new one containing only the new project name.
$readmePath = Join-Path $root 'README.md'
if (Test-Path $readmePath) {
    Remove-Item -LiteralPath $readmePath -Force
}
Set-Content -LiteralPath $readmePath -Value "# $Name`n" -Encoding utf8
Write-Output "Replaced README at $readmePath"

Write-Output "Initialize complete."
Write-Output "If you use VS Code, run the task 'Initialize Godot Template' or execute Scripts\InitializeProject.ps1 directly."