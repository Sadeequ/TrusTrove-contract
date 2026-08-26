#!/usr/bin/env pwsh
# update-readme-addresses.ps1 — Updates README.md with deployed addresses from deployments.json
#
# This script updates the README.md with the currently deployed addresses
# by reading deployments.json. It relies on the injection markers:
# <!-- START_DEPLOYED_ADDRESSES -->
# <!-- END_DEPLOYED_ADDRESSES -->

$ErrorActionPreference = 'Stop'

$RepoRoot = git rev-parse --show-toplevel 2>$null
if (-not $RepoRoot) {
    Write-Host "Error: Not in a git repository."
    exit 1
}

$ReadmePath = Join-Path $RepoRoot "README.md"
$DeploymentsFile = Join-Path $RepoRoot "deployments.json"

if (-not (Test-Path $DeploymentsFile)) {
    Write-Host "Error: $DeploymentsFile not found. Cannot update README.md."
    exit 1
}

if (-not (Test-Path $ReadmePath)) {
    Write-Host "Error: $ReadmePath not found."
    exit 1
}

Write-Host "Updating README.md with latest deployed addresses from deployments.json..."

$deployments = Get-Content $DeploymentsFile -Raw | ConvertFrom-Json

$registry = $deployments.registry
$invoice = $deployments.invoice
$escrow_usdc = $deployments.escrow_usdc
$pool_usdc = $deployments.pool_usdc

$newTable = @"
| Contract | Address |
|----------|---------|
| registry_contract | `$registry` |
| invoice_contract | `$invoice` |
| escrow_contract | `$escrow_usdc` |
| pool_contract | `$pool_usdc` |
"@

$readmeContent = Get-Content $ReadmePath -Raw
$pattern = '(?s)<!-- START_DEPLOYED_ADDRESSES -->.*?<!-- END_DEPLOYED_ADDRESSES -->'
$replacement = "<!-- START_DEPLOYED_ADDRESSES -->`n$newTable`n<!-- END_DEPLOYED_ADDRESSES -->"
$updatedContent = $readmeContent -replace $pattern, $replacement

if ($updatedContent -eq $readmeContent) {
    Write-Host "Warning: Deployment markers not found in README.md. No changes made."
    exit 0
}

Set-Content -Path $ReadmePath -Value $updatedContent -NoNewline
Write-Host "README.md successfully updated with contract addresses."
