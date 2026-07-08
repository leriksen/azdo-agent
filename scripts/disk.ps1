- task: PowerShell@2
  displayName: 'Show disk space'
  inputs:
    targetType: 'inline'
    pwsh: true
    script: |
      $threshold = 95

      $drives = Get-PSDrive -PSProvider FileSystem |
          Where-Object { $_.Free -ne $null -and ($_.Used + $_.Free) -gt 0 -and ($IsLinux -or $IsMacOS -or -not $_.DisplayRoot) } |
          Select-Object Name,
              @{N='UsedGB';  E={[math]::Round($_.Used / 1GB, 2)}},
              @{N='FreeGB';  E={[math]::Round($_.Free / 1GB, 2)}},
              @{N='TotalGB'; E={[math]::Round(($_.Used + $_.Free) / 1GB, 2)}},
              @{N='UsedPct'; E={[math]::Round($_.Used / ($_.Used + $_.Free) * 100, 1)}}

      $drives | Format-Table -AutoSize

      $overThreshold = $drives | Where-Object { $_.UsedPct -gt $threshold }

      foreach ($drive in $overThreshold) {
          Write-Host "##vso[task.logissue type=warning]Drive '$($drive.Name)' is at $($drive.UsedPct)% usage ($($drive.FreeGB) GB free of $($drive.TotalGB) GB) - exceeds $threshold% threshold"
      }

      if ($overThreshold) {
          Write-Host "##vso[task.complete result=SucceededWithIssues;]Disk space check found $(@($overThreshold).Count) drive(s) over $threshold%"
      }
      else {
          Write-Host "All drives below $threshold% usage threshold"
      }
