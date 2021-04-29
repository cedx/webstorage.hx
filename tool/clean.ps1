#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
Set-Location (Split-Path $PSScriptRoot)
Remove-Item var/* -Exclude .gitkeep -Force -Recurse
