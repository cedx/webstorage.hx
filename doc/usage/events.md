# Events
The [`WebStorage`](api.md) class is an [`EventTarget`](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget): every time one or several values are changed (added, removed or updated) through this class, a [`StorageEvent`](https://developer.mozilla.org/en-US/docs/Web/API/StorageEvent) of type `change` is emitted.

!!! tip
	If you target browsers that do not support the `EventTarget` constructor, you will need a dedicated polyfill.
	We recommend using the [`@ungap/event-target`](https://www.npmjs.com/package/@ungap/event-target) package.   

You can subscribe to these `change` events using the `addEventListener()` method:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main(): Void {
				final service = new LocalStorage();
				service.addEventListener("change", event -> {
					trace('${event.key}: ${event.oldValue} => ${event.newValue}');
				});

				service.set("foo", "bar"); // "foo: null => bar"
				service.set("foo", "baz"); // "foo: bar => baz"
				service.remove("foo"); // "foo: baz => null"
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			const service = new LocalStorage;
			service.addEventListener("change", event => {
				console.log(`${event.key}: ${event.oldValue} => ${event.newValue}`);
			});

			service.set("foo", "bar"); // "foo: undefined => bar"
			service.set("foo", "baz"); // "foo: bar => baz"
			service.remove("foo"); // "foo: baz => undefined"
		}

The values contained in the `newValue` and `oldValue` properties of the [`StorageEvent`](https://developer.mozilla.org/en-US/docs/Web/API/StorageEvent) instances are the raw storage values.
If you use the `WebStorage.setObject()` method to store a value, you will get the serialized string value, not the original value passed to the method:

=== "Haxe"
		:::haxe
		service.setObject("foo", {bar: "baz"});
		// "foo: null => {\"bar\": \"baz\"}"

=== "JavaScript"
		:::js
		service.setObject("foo", {bar: "baz"});
		// "foo: undefined => {\"bar\": \"baz\"}"

## Changes in the context of another document
The `LocalStorage` and `SessionStorage` classes support the global [storage events](https://developer.mozilla.org/en-US/docs/Web/API/Window/storage_event).

When a change is made to the storage area within the context of another document (i.e. in another tab or `<iframe>`), a `change` event can be emitted to notify the modification.

The class constructors have an optional `listenToGlobalEvents` parameter that allows to enable the subscription to the global storage events:

=== "Haxe"
		:::haxe
		import webstorage.LocalStorage;

		class Main {
			static function main(): Void {
				// Enable the subscription to the global events of the local storage.
				final service = new LocalStorage({listenToGlobalEvents: true});

				// Also occurs when the local storage is changed in another document.
				service.addEventListener("change", event -> { /* ... */ });

				// Later, cancel the subscription to the global storage events.
				service.destroy();
			}
		}

=== "JavaScript"
		:::js
		import {LocalStorage} from "@cedx/webstorage.hx";

		function main() {
			// Enable the subscription to the global events of the local storage.
			const service = new LocalStorage({listenToGlobalEvents: true});

			// Also occurs when the local storage is changed in another document.
			service.addEventListener("change", event => { /* ... */ });

			// Later, cancel the subscription to the storage events.
			service.destroy();
		}

!!! important
	When you enable the subscription to the global [storage events](https://developer.mozilla.org/en-US/docs/Web/API/Window/storage_event), you must take care to call the [`destroy()` method](api.md) when you have finished with the service in order to avoid a memory leak.
