# Installation

## Requirements
Before installing **WebStorage.hx**, you need to make sure you have either
[Haxe](https://haxe.org) or [Node.js](https://nodejs.org) up and running.

You can verify if you're already good to go with the following commands:

<!-- tabs:start -->

#### **Haxe**
```shell
haxe --version
# 4.1.4

haxelib version
# 4.0.2
```

#### **JavaScript**
```shell
node --version
# v15.4.0

npm --version
# 7.0.15
```

<!-- tabs:end -->

?> If you plan to play with the package sources, you will also need [PowerShell](https://docs.microsoft.com/en-us/powershell).

## Installing with a package manager

<!-- tabs:start -->

#### **Haxe**
From a command prompt, run:

```shell
haxelib install webstorage
```

Now in your [Haxe](https://haxe.org) code, you can use:

```haxe
import webstorage.LocalStorage;
import webstorage.SessionStorage;
```

#### **JavaScript**
From a command prompt, run:

```shell
npm install @cedx/webstorage.hx
```

Now in your [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript) code, you can use:

```javascript
// CommonJS module.
const {LocalStorage, SessionStorage} = require("@cedx/webstorage.hx");

// ECMAScript module.
import {LocalStorage, SessionStorage} from "@cedx/webstorage.hx";
```

<!-- tabs:end -->

## Installing from a content delivery network
This library is also available as a ready-made JavaScript bundle.
To install it, add one of these code snippets to the `<head>` of your HTML document:

```html
<!-- jsDelivr -->
<script src="https://cdn.jsdelivr.net/npm/@cedx/webstorage.hx/build/webstorage.min.js"></script>

<!-- UNPKG -->
<script src="https://unpkg.com/@cedx/webstorage.hx/build/webstorage.min.js"></script>
```

The classes of this library are exposed as `webstorage` property on the `window` global object:

```html
<script>
	const {LocalStorage, SessionStorage} = window.webstorage;
</script>
```
