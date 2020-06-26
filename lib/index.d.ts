export declare abstract class WebStorage extends EventTarget implements Iterable<[string, string]> {
	protected constructor(backend: Storage, options?: WebStorageOptions);
	readonly keys: string[];
	readonly length: number;
	[Symbol.iterator](): IterableIterator<[string, string]>;
	clear(): void;
	destroy(): void;
	exists(key: string): boolean;
	get(key: string, defaultValue?: string): string|undefined;
	getObject(key: string, defaultValue?: unknown): any;
	putIfAbsent(key: string, ifAbsent: () => string): string;
	putObjectIfAbsent(key: string, ifAbsent: () => any): any;
	remove(key: string): string|undefined;
	set(key: string, value: string): this;
	setObject(key: string, value: unknown): this;
	toJSON(): Record<string, string>;
}

export interface WebStorageOptions {
	listenToGlobalEvents: boolean;
}

export declare class LocalStorage extends WebStorage {
	constructor(options?: WebStorageOptions);
}

export declare class SessionStorage extends WebStorage {
	constructor(options?: WebStorageOptions);
}
