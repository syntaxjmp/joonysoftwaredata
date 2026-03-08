$ErrorActionPreference = 'Stop'
$NetClassGuid = '{4D36E972-E325-11CE-BFC1-08002bE10318}'
$RegBase = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\$NetClassGuid"

$MacToSpoof = '16FF0B953DDB'

$physicalAdapters = Get-CimInstance -ClassName Win32_NetworkAdapter -Filter 'PhysicalAdapter=True'

foreach ($adapter in $physicalAdapters) {
    $deviceId = $adapter.DeviceID
    $mac      = $MacToSpoof

    $prefixes = @('', '0', '00', '000')
    $set      = $false
    foreach ($prefix in $prefixes) {
        $keyName = $prefix + $deviceId
        $path    = Join-Path $RegBase $keyName
        try {
            if (Test-Path -LiteralPath $Path) {
                Set-ItemProperty -LiteralPath $path -Name 'NetworkAddress' -Value $mac -Type String -Force
                $set = $true
                break
            }
        } catch {}
    }
    if (-not $set) {
        $path4 = Join-Path $RegBase ('{0:D4}' -f [int]$deviceId)
        try {
            if (Test-Path -LiteralPath $path4) {
                Set-ItemProperty -LiteralPath $path4 -Name 'NetworkAddress' -Value $mac -Type String -Force
            }
        } catch {}
    }
}

foreach ($adapter in $physicalAdapters) {
    $deviceId  = $adapter.DeviceID
    $prefixes  = @('', '0', '00', '000')
    $set       = $false
    foreach ($prefix in $prefixes) {
        $path = Join-Path $RegBase ($prefix + $deviceId)
        try {
            if (Test-Path -LiteralPath $path) {
                Set-ItemProperty -LiteralPath $path -Name 'PnPCapabilities' -Value 24 -Type DWord -Force
                $set = $true
                break
            }
        } catch {}
    }
    if (-not $set) {
        $path4 = Join-Path $RegBase ('{0:D4}' -f [int]$deviceId)
        try {
            if (Test-Path -LiteralPath $path4) {
                Set-ItemProperty -LiteralPath $path4 -Name 'PnPCapabilities' -Value 24 -Type DWord -Force
            }
        } catch {}
    }
}

Get-NetAdapter | ForEach-Object {
    $name = $_.Name
    try {
        netsh interface set interface name="`"$name`"" disable 2>$null
        netsh interface set interface name="`"$name`"" enable  2>$null
    } catch {}
}
