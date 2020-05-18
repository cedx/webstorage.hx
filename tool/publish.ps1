#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
Set-Location (Split-Path $PSScriptRoot)

$files = @(
	"*.md",
	"haxelib.json",
	"build",
	"src"
)

tool/dist.ps1
Compress-Archive $files var/haxelib.zip -Force
haxelib submit var/haxelib.zip
npm publish
