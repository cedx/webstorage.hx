# Changelog

## Version [2.0.0](https://github.com/cedx/webstorage.hx/compare/v1.0.5...v2.0.0)
- Breaking change: the `WebStorage` class no longer extends from [`EventTarget`](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget).
- Added support for key prefix.
- Added support for [`tink_json`](https://github.com/haxetink/tink_json) serialization.

## Version [1.0.5](https://github.com/cedx/webstorage.hx/compare/v1.0.4...v1.0.5)
- Fixed the handling of global [storage events](https://developer.mozilla.org/en-US/docs/Web/API/Window/storage_event).
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
