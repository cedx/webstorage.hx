#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
Set-Location (Split-Path $PSScriptRoot)

haxe test.hxml
node_modules/.bin/karma start etc/karma.js
