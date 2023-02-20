# Changelog

## Version [5.0.0](https://github.com/cedx/webstorage.hx/compare/v4.0.3...v5.0.0)
- Breaking change: removed the `LocalStorage` and `SessionStorage` classes.
- Fixed the typings.

## Version [4.0.3](https://github.com/cedx/webstorage.hx/compare/v4.0.2...v4.0.3)
- Fixed the handling of global [storage events](https://developer.mozilla.org/docs/Web/API/Window/storage_event).

## Version [4.0.2](https://github.com/cedx/webstorage.hx/compare/v4.0.1...v4.0.2)
- Updated the project URL.

## Version [4.0.1](https://github.com/cedx/webstorage.hx/compare/v4.0.0...v4.0.1)
- Fixed the event handling when a key prefix is set.

## Version [4.0.0](https://github.com/cedx/webstorage.hx/compare/v3.1.0...v4.0.0)
- Breaking change: reworked the event system by using a custom `StorageEvent` class.

## Version [3.1.0](https://github.com/cedx/webstorage.hx/compare/v3.0.0...v3.1.0)
- Optimized the performance of the `putIfAbsent()` methods.
- The `keyPrefix` property is now private.

## Version [3.0.0](https://github.com/cedx/webstorage.hx/compare/v2.0.0...v3.0.0)
- Breaking change: the getter methods now return `haxe.ds.Option` instances.
- Breaking change: the setter methods now return `tink.core.Outcome` instances.
- Breaking change: removed the `defaultValue` parameter from the getter methods.

## Version [2.0.0](https://github.com/cedx/webstorage.hx/compare/v1.0.5...v2.0.0)
- Breaking change: renamed the `WebStorage` class to `Storage`.
- Breaking change: the `Storage` class no longer extends from [`EventTarget`](https://developer.mozilla.org/docs/Web/API/EventTarget).
- Breaking change: the `Storage` class is now `abstract`.
- Breaking change: the `LocalStorage` and `SessionStorage` classes are now `final`.
- Added support for key prefix.
- Dropped the [npm](https://www.npmjs.com) package.
- Ported the tests to [Tinberkell](https://haxetink.github.io/tink_unittest).
- Replaced the build system based on [PowerShell](https://docs.microsoft.com/en-us/powershell) by [lix](https://github.com/lix-pm/lix.client) scripts.
- Updated the documentation.

## Version [1.0.5](https://github.com/cedx/webstorage.hx/compare/v1.0.4...v1.0.5)
- Fixed the handling of global [storage events](https://developer.mozilla.org/docs/Web/API/Window/storage_event).
- Ported the documentation to [docsify](https://docsify.js.org).

## Version [1.0.4](https://github.com/cedx/webstorage.hx/compare/v1.0.3...v1.0.4)
- The `getObject()` and `putObjectIfAbsent()` methods of the `WebStorage` class are now generic.

## Version [1.0.3](https://github.com/cedx/webstorage.hx/compare/v1.0.2...v1.0.3)
- Fixed the [npm](https://www.npmjs.com) packaging.
- Updated the documentation.

## Version [1.0.2](https://github.com/cedx/webstorage.hx/compare/v1.0.1...v1.0.2)
- Fixed the [Haxelib](https://lib.haxe.org) badges.

## Version [1.0.1](https://github.com/cedx/webstorage.hx/compare/v1.0.0...v1.0.1)
- Fixed the [Haxelib](https://lib.haxe.org) packaging.

## Version 1.0.0
- Initial release.
