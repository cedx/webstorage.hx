# Installation

## Requirements
Before installing **Web Storage for Haxe**, you need to make sure you have [Haxe](https://haxe.org) up and running.
You can verify if you're already good to go with the following command:

```shell
haxe --version
# 4.3.1
```

## Installing with a package manager

### 1. Install it
From a command prompt, run:

<!-- tabs:start -->

#### **haxelib**

```shell
haxelib install webstorage
```

#### **lix**

```shell
lix +lib webstorage
```

<!-- tabs:end -->

### 2. Import it
Add this line to your [`.hxml`](https://haxe.org/manual/compiler-usage-hxml.html) build file:

```hxml
--library webstorage
```

Now in your [Haxe](https://haxe.org) code, you can use:

```haxe
import webstorage.*;
```
