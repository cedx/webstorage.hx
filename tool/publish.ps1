#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
Set-Location (Split-Path $PSScriptRoot)

tool/dist.ps1
haxelib submit
npm publish --registry=https://registry.npmjs.org
