- task: PowerShell@2
  displayName: 'Show average CPU (60s)'
  inputs:
    targetType: 'inline'
    pwsh: true
    script: |
      if ($IsWindows) {
          # Sample once per second for 60 seconds, then average
          $samples = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 60
          $avg = ($samples.CounterSamples.CookedValue | Measure-Object -Average).Average
      }
      else {
          # Linux: read /proc/stat at start and end of a 60s window.
          # The deltas give the true average over the whole period.
          function Get-CpuTimes {
              $fields = (Get-Content /proc/stat -TotalCount 1) -split '\s+' | Select-Object -Skip 1
              $total = ($fields | Measure-Object -Sum).Sum
              $idle  = [long]$fields[3] + [long]$fields[4]   # idle + iowait
              return @{ Total = $total; Idle = $idle }
          }

          $start = Get-CpuTimes
          Start-Sleep -Seconds 60
          $end = Get-CpuTimes

          $totalDelta = $end.Total - $start.Total
          $idleDelta  = $end.Idle  - $start.Idle
          $avg = (1 - ($idleDelta / $totalDelta)) * 100
      }

      Write-Host ("Average CPU over last 60 seconds: {0:N1}%" -f $avg)
