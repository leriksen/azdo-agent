- task: PowerShell@2
  displayName: 'Dump environment variables'
  inputs:
    targetType: 'inline'
    pwsh: true
    script: |
      $vars = Get-ChildItem Env: | Sort-Object Name
      Write-Host "Total environment variables: $($vars.Count)"
      Write-Host ""
      $vars | ForEach-Object { Write-Host "$($_.Name)=$($_.Value)" }
