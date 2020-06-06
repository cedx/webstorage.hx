#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
Set-Location (Split-Path $PSScriptRoot)

tool/clean.ps1
tool/version.ps1
haxe build.hxml

if (-not (Test-Path build)) { New-Item build -ItemType Directory | Out-Null }
Copy-Item lib/webstorage.js build/webstorage.js
node_modules/.bin/terser --config-file=etc/terser.json --output=build/webstorage.min.js build/webstorage.js
