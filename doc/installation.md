# Installation

## Requirements
Before installing **WebStorage.hx**, you need to make sure you have either
[Haxe](https://haxe.org) or [Node.js](https://nodejs.org) up and running.

You can verify if you're already good to go with the following commands:

=== "Haxe"
		:::shell
		haxe --version
		# 4.1.0

		haxelib version
		# 4.0.2

=== "JavaScript"
		:::shell
		node --version
		# v14.3.0

		npm --version
		# 6.14.5

!!! info
	If you plan to play with the package sources, you will also need
	[PowerShell](https://docs.microsoft.com/en-us/powershell) and [Material for MkDocs](https://squidfunk.github.io/mkdocs-material).

## Installing with a package manager

=== "Haxe"
	### 1. Install it
	From a command prompt, run:

		:::shell
		haxelib install webstorage

	### 2. Import it
	Now in your [Haxe](https://haxe.org) code, you can use:

		:::haxe
		import webstorage.LocalStorage;
		import webstorage.SessionStorage;

=== "JavaScript"
	### 1. Install it
	From a command prompt, run:

		:::shell
		npm install @cedx/webstorage.hx

	### 2. Import it
	Now in your [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript) code, you can use:

		:::js
		// CommonJS module.
		const {LocalStorage, SessionStorage} = require("@cedx/webstorage.hx");

		// ECMAScript module.
		import {LocalStorage, SessionStorage} from "@cedx/webstorage.hx";

## Installing from a content delivery network
This library is also available as a ready-made JavaScript bundle.
To install it, add one of these code snippets to the `<head>` of your HTML document:

``` html
<!-- jsDelivr -->
<script src="https://cdn.jsdelivr.net/npm/@cedx/webstorage.hx/build/webstorage.min.js"></script>

<!-- UNPKG -->
<script src="https://unpkg.com/@cedx/webstorage.hx/build/webstorage.min.js"></script>
```

The classes of this library are exposed as `webstorage` property on the `window` global object:

``` html
<script>
	const {LocalStorage, SessionStorage} = window.webstorage;
</script>
```
