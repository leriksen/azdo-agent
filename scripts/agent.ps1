#!/usr/bin/env pwsh

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$AdoOrgUrl = "$(System.CollectionUri)"
$PoolName  = $env:POOLNAME

$headers = @{
    'Authorization' = "Bearer $(ADO_TOKEN)"
    'Content-Type'  = 'application/json'
}

$poolResponse = Invoke-RestMethod -Method Get -Headers $headers `
    -Uri "${AdoOrgUrl}_apis/distributedtask/pools" `
    -Body @{ poolName = $PoolName; 'api-version' = '7.1' }

$poolId = $poolResponse.value | Select-Object -First 1 -ExpandProperty id -ErrorAction SilentlyContinue

if (-not $poolId) {
    Write-Host "##vso[task.logissue type=error]Pool not found in response"
    exit 1
}

$agentsResponse = Invoke-RestMethod -Method Get -Headers $headers `
    -Uri "${AdoOrgUrl}_apis/distributedtask/pools/${poolId}/agents?api-version=7.1"

$agents = @($agentsResponse.value)

# Online + enabled: eligible for jobs, these become the matrix.
$enabled = @(
    $agents |
        Where-Object { "$($_.status)".ToLower() -eq 'online' -and $_.enabled -eq $true } |
        Select-Object -ExpandProperty name |
        Sort-Object -Unique
)

# Online but manually disabled: running, but excluded from receiving jobs.
$disabled = @(
    $agents |
        Where-Object { "$($_.status)".ToLower() -eq 'online' -and $_.enabled -ne $true } |
        Select-Object -ExpandProperty name |
        Sort-Object -Unique
)

# Offline: not reachable, regardless of enabled flag.
$offline = @(
    $agents |
        Where-Object { "$($_.status)".ToLower() -ne 'online' } |
        Select-Object -ExpandProperty name |
        Sort-Object -Unique
)

$matrix = [ordered]@{}
for ($i = 0; $i -lt $enabled.Count; $i++) {
    $matrix["agent_$($i + 1)"] = @{ agentName = $enabled[$i] }
}

$enabledAgents = $matrix | ConvertTo-Json -Compress -Depth 10
$enabledCount  = $enabled.Count
$disabledCount = $disabled.Count
$disabledNames = $disabled -join ', '
$offlineCount  = $offline.Count
$offlineNames  = $offline -join ', '

Write-Host "Enabled agents: $enabledCount"
Write-Host "Disabled agents: $disabledCount"

if ($disabledCount -gt 0) {
    Write-Host "##vso[task.logissue type=warning]Some agents are online but disabled (manually excluded from jobs): $disabledNames"
}

if ($offlineCount -gt 0) {
    Write-Host "##vso[task.logissue type=error]Some agents are offline: $offlineNames"
    exit 1
}

if ($enabledAgents -eq '{}') {
    Write-Host "##vso[task.logissue type=error]No enabled agents found in pool"
    exit 1
}

Write-Host "##vso[task.setvariable variable=ENABLED_AGENTS;isOutput=true]$enabledAgents"
Write-Host "##vso[task.setvariable variable=AGENT_ENABLED_COUNT;isOutput=true]$enabledCount"
Write-Host "##vso[task.setvariable variable=DISABLED_AGENTS;isOutput=true]$disabledNames"
Write-Host "##vso[task.setvariable variable=AGENT_DISABLED_COUNT;isOutput=true]$disabledCount"
