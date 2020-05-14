declare type Json = null | boolean | number | string | Json[] | {
  [property: string]: Json;
};

declare abstract class WebStorage extends EventTarget implements Iterable<[string, string]> {
  protected constructor(backend: Storage, options?: StorageOptions);
  get keys(): string[];
  get length(): number;
  [Symbol.iterator](): IterableIterator<[string, string]>;
  clear(): void;
  destroy(): void;
  get(key: string, defaultValue?: string): string|undefined;
  getObject(key: string, defaultValue?: any): any;
  has(key: string): boolean;
  putIfAbsent(key: string, ifAbsent: () => string): string;
  putObjectIfAbsent(key: string, ifAbsent: () => any): any;
  remove(key: string): string|undefined;
  set(key: string, value: string): this;
  setObject(key: string, value: any): this;
  toJSON(): Record<string, Json>;
}

export interface StorageOptions {
  listenToStorageEvents: boolean;
}

export declare class LocalStorage extends WebStorage {
  constructor(options?: StorageOptions);
}

export declare class SessionStorage extends WebStorage {
  constructor(options?: StorageOptions);
}
