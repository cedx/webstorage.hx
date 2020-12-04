#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
Set-Location (Split-Path $PSScriptRoot)

$version = (Get-Content haxelib.json | ConvertFrom-Json).version
haxe --define doc-gen --xml var/api.xml build.hxml
haxelib run dox `
	--define description "Services for interacting with the Web Storage, in Haxe and JavaScript. An event-based API to manage storage changes." `
	--define source-path "https://git.belin.io/cedx/webstorage.hx/src/branch/main/src" `
	--define themeColor 0xffc105 `
	--define version $version `
	--define website "https://belin.io" `
	--input-path var `
	--output-path docs/api `
	--title "WebStorage.hx" `
	--toplevel-package webstorage

Copy-Item docs/favicon.ico docs/api
