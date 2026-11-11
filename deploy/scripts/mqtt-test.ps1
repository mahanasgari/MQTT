# Test MQTT publish (PowerShell)
# Usage:
#   .\deploy\scripts\mqtt-test.ps1 -Mode local
#   .\deploy\scripts\mqtt-test.ps1 -Mode remote

param(
    [ValidateSet("local", "remote")]
    [string]$Mode = "local",
    [string]$Serial = "SP00000001"
)

$envFile = Join-Path $PSScriptRoot "..\..\.env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
        }
    }
}

$user = if ($env:MQTT_USERNAME) { $env:MQTT_USERNAME } else { "smartplug-backend" }
$pass = if ($env:MQTT_PASSWORD) { $env:MQTT_PASSWORD } else { "devpass" }
$port = if ($env:MQTT_BROKER_PORT) { $env:MQTT_BROKER_PORT } else { "1883" }

if ($Mode -eq "remote") {
    if (-not $env:MQTT_BROKER_HOST) { throw "Set MQTT_BROKER_HOST in .env" }
    $host = $env:MQTT_BROKER_HOST
} else {
    $host = if ($env:MQTT_HOST) { $env:MQTT_HOST } else { "localhost" }
}

$topic = "tele/$Serial/state"
$payload = '{"power":"off","connectivity":"online"}'

Write-Host "Publishing to ${host}:${port} topic=$topic"
mosquitto_pub -h $host -p $port -u $user -P $pass -t $topic -m $payload
Write-Host "OK"
