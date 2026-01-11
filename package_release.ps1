
# n8n Release Packaging Script
# Creates TWO .tgz archives using a WHITELIST approach:
# 1. n8n-release-light-*.tgz: No node_modules
# 2. n8n-release-full-*.tgz: Top-level node_modules included

$ErrorActionPreference = "Stop"
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmm'

# === configuration ===
# Whitelist: Only these top-level items will be checked for inclusion
$IncludePaths = @(
    "package.json",
    "pnpm-lock.yaml",
    "pnpm-workspace.yaml",
    ".npmrc",
    "turbo.json",
    "tsconfig.json",
    "patches",
    "scripts",
    "packages",
    "DEPLOY_GUIDE_CN.md",
    ".env.demo",
    "start.bat",
    "start.sh"
)

# Global Exclusions: Always excluded, even if inside an included folder
$BaseExcludes = @(
    ".git",
    ".github",
    ".vscode",
    ".devcontainer",
    "docker",
    "*.log",
    "tmp",
    ".cache",
    ".turbo",
    "*.tgz",
    "*.zip",
		".npmrc",
    "temp_package_build",
    "tests",
    "test",
    "patches",
    "scripts",
    "*.tsbuildinfo",
    "node_modules"  # Excluded by default, re-added for FULL if needed (via negation or specialized logic)
)

function Create-TarPackage {
    param (
        [string]$NameSuffix,
        [bool]$IncludeModules
    )

    $FileName = "n8n-release-${NameSuffix}-${Timestamp}.tgz"
    Write-Host "`n=== Creating $NameSuffix package: $FileName ==="

    $TarArgs = @("czf", $FileName)

    # Exclusions
    # Note: For strict exclusion of ALL node_modules, we add it to excludes.
    # For 'Full', we want to ALLOW node_modules.
    # Since 'node_modules' is in BaseExcludes, we must handle it.

    foreach ($exc in $BaseExcludes) {
        if ($IncludeModules -and $exc -eq "node_modules") {
            continue # Skip excluding node_modules for FULL build
        }
        $TarArgs += "--exclude=$exc"
    }

    # Add Whitelisted Paths
    # We only add them if they exist
    foreach ($path in $IncludePaths) {
        if (Test-Path $path) {
            $TarArgs += $path
        }
    }

    # If Full build, we also need to include the top-level node_modules IF it's not covered by the whitelist
    # (The whitelist generally covers folders. Top level 'node_modules' is NOT in the whitelist above.
    # So for Full build, we must explicitly add "node_modules" to the file list)
    if ($IncludeModules -and (Test-Path "node_modules")) {
        $TarArgs += "node_modules"
    }

    # Construct command string for visual verification & execution
    # PowerShell passing args to external exe can be finicky, using direct execution with args array is safer if Start-Process,
    # but Invoke-Expression string construction offers transparency for tar's flags.

    # Re-building command string for Invoke-Expression to handle quotes consistency
    $CmdString = "tar"
    foreach ($arg in $TarArgs) {
        # Check if arg looks like a flag
        if ($arg -match "^--") {
            # Quote value part if exists
            if ($arg -match "=") {
                 $parts = $arg -split "=", 2
                 $CmdString += " " + $parts[0] + "=""" + $parts[1] + """"
            } else {
                 $CmdString += " " + $arg
            }
        } else {
            # File path, quote it
            $CmdString += " ""$arg"""
        }
    }

    # Write-Host "Command: $CmdString"
    Invoke-Expression $CmdString

    if ($LASTEXITCODE -eq 0) {
        $SizeMB = "{0:N2}" -f ((Get-Item $FileName).Length / 1MB)
        Write-Host "SUCCESS: Created $FileName ($SizeMB MB)"
    } else {
        Write-Host "ERROR: Failed to create $FileName (Exit Code: $LASTEXITCODE)"
    }
}

# 1. Create LIGHT Package
Create-TarPackage -NameSuffix "light" -IncludeModules $false

# 2. Create FULL Package
Create-TarPackage -NameSuffix "full" -IncludeModules $true

Write-Host "`nDone."
