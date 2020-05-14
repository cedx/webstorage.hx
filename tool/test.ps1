#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
Set-Location (Split-Path $PSScriptRoot)

haxe build.hxml
node_modules/.bin/karma start etc/karma.js
