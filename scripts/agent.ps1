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

$online = @(
    $agents |
        Where-Object { $_.enabled -eq $true -and "$($_.status)".ToLower() -eq 'online' } |
        Select-Object -ExpandProperty name |
        Sort-Object -Unique
)

$offline = @(
    $agents |
        Where-Object { $_.enabled -eq $true -and "$($_.status)".ToLower() -ne 'online' } |
        Select-Object -ExpandProperty name |
        Sort-Object -Unique
)

$disabled = @(
    $agents |
        Where-Object { $_.enabled -ne $true } |
        Select-Object -ExpandProperty name |
        Sort-Object -Unique
)

$matrix = [ordered]@{}
for ($i = 0; $i -lt $online.Count; $i++) {
    $matrix["agent_$($i + 1)"] = @{ agentName = $online[$i] }
}

$onlineAgents = $matrix | ConvertTo-Json -Compress -Depth 10
$onlineCount = $online.Count
$offlineCount = $offline.Count
$offlineNames = $offline -join ', '
$disabledCount = $disabled.Count
$disabledNames = $disabled -join ', '

Write-Host "Online agents: $onlineCount"
Write-Host "Disabled agents: $disabledCount"

if ($disabledCount -gt 0) {
    Write-Host "##vso[task.logissue type=warning]Some agents are disabled (manually excluded from jobs): $disabledNames"
}

if ($offlineCount -gt 0) {
    Write-Host "##vso[task.logissue type=error]Some agents are offline: $offlineNames"
    exit 1
}

if ($onlineAgents -eq '{}') {
    Write-Host "##vso[task.logissue type=error]No online agents found in pool"
    exit 1
}

Write-Host "##vso[task.setvariable variable=ONLINE_AGENTS;isOutput=true]$onlineAgents"
Write-Host "##vso[task.setvariable variable=AGENT_ONLINE_COUNT;isOutput=true]$onlineCount"
Write-Host "##vso[task.setvariable variable=DISABLED_AGENTS;isOutput=true]$disabledNames"
Write-Host "##vso[task.setvariable variable=AGENT_DISABLED_COUNT;isOutput=true]$disabledCount"