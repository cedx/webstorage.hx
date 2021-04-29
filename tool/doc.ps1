#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
Set-Location (Split-Path $PSScriptRoot)

if (Test-Path docs/api) { Remove-Item docs/api -Force -Recurse }

$version = (Get-Content haxelib.json | ConvertFrom-Json).version
haxe --define doc-gen --no-output --xml var/api.xml build.hxml
lix run dox `
	--define description "Services for interacting with the Web Storage, in Haxe. An event-based API to manage storage changes." `
	--define source-path "https://github.com/cedx/webstorage.hx/blob/main/src" `
	--define themeColor 0xffc105 `
	--define version $version `
	--define website "https://cedx.github.io/webstorage.hx" `
	--input-path var `
	--output-path docs/api `
	--title "Web Storage for Haxe" `
	--toplevel-package webstorage

Copy-Item docs/favicon.ico docs/api
