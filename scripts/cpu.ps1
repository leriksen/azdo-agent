- task: PowerShell@2
  displayName: 'Show CPU load'
  inputs:
    targetType: 'inline'
    pwsh: true
    script: |
      $threshold = 90

      if ($IsWindows) {
          # No kernel-maintained average on Windows; take a short 5s sample as a proxy
          $samples = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 5
          $avg = ($samples.CounterSamples.CookedValue | Measure-Object -Average).Average
          $label = "CPU (5s sample average)"
      }
      else {
          # Kernel-maintained 1-minute load average - instant read
          $load1 = [double]((Get-Content /proc/loadavg) -split '\s+')[0]
          $cores = [Environment]::ProcessorCount
          $avg = ($load1 / $cores) * 100
          $label = "CPU (1-min load average, $load1 across $cores cores)"
      }

      Write-Host ("{0}: {1:N1}%" -f $label, $avg)

      if ($avg -gt $threshold) {
          Write-Host "##vso[task.logissue type=warning]$label is at $([math]::Round($avg,1))% - exceeds $threshold% threshold"
          Write-Host "##vso[task.complete result=SucceededWithIssues;]High CPU load detected"
      }
      else {
          Write-Host "CPU below $threshold% threshold"
      }
