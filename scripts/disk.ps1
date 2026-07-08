- pwsh: |
    Get-PSDrive -PSProvider FileSystem |
        Where-Object { $_.Free -ne $null -and ($IsLinux -or $IsMacOS -or -not $_.DisplayRoot) } |
        Select-Object Name,
            @{N='Used(GB)';E={[math]::Round($_.Used/1GB,2)}},
            @{N='Free(GB)';E={[math]::Round($_.Free/1GB,2)}},
            @{N='Total(GB)';E={[math]::Round(($_.Used+$_.Free)/1GB,2)}} |
        Format-Table -AutoSize
  displayName: 'Show disk space'
