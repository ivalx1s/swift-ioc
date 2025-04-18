import Foundation

@usableFromInline
final class AtomicMap<Key: Hashable, Value>: @unchecked Sendable {
    private var storage: [Key: Value] = [:]
    private let lock = NSLock()

    @usableFromInline
    @discardableResult
    func removeValue(forKey key: Key) -> Value? {
        lock.withLock {
            storage.removeValue(forKey: key)
        }
    }

    @usableFromInline
    func contains(key: Key) -> Bool {
        lock.withLock {
            storage.keys.contains(key)
        }
    }

    @usableFromInline
    var keys: [Key] {
        lock.withLock {
            Array(storage.keys)
        }
    }

    @usableFromInline
    var values: [Value] {
        lock.withLock {
            Array(storage.values)
        }
    }

    @usableFromInline
    subscript(key: Key) -> Value? {
        get {
            lock.withLock {
                storage[key]
            }
        }
        set {
            lock.withLock {
                storage[key] = newValue
            }
        }
    }
}
