import Foundation

public final class IoC: @unchecked Sendable {
    public typealias Key = ObjectIdentifier

    @usableFromInline
    internal
    let lock: NSLock = NSLock()

    @usableFromInline
    internal private(set)
    var mapForSync: [Key: any SyncResolver] = [:]

    @usableFromInline
    internal private(set)
    var mapForAsync: [Key: any AsyncResolver] = [:]

    @usableFromInline
    internal let logger: ILogger

    @inlinable @inline(__always)
    public init(
        logger: ILogger = Logger()
    ) {
        self.logger = logger
    }
}

extension IoC {
    @inlinable @inline(__always)
    func key(of obj: Any) -> ObjectIdentifier { .init(type(of: obj)) }

    @inlinable @inline(__always)
    static func key(of type: Any.Type) -> ObjectIdentifier { .init(type) }
}

// registration
extension IoC {
    @inlinable @inline(__always)
    public func register<T>(
        _ type: T.Type,
        lifecycle: Lifecycle = .transient,
        withReplacement: Bool = false,
        resolver: @escaping () -> T
    ) {
        let key = key(of: type)

        guard withReplacement
                || self.mapForSync[key] == nil else {
            fatalError("failed to register \(type), already registered")
        }

        lock.withLock {
            self.mapForSync[key] = switch lifecycle {
                case .container: SyncContainerResolver(build: resolver)
                case .transient: SyncTransientResolver(build: resolver)
            }
        }


        logger.send("type: \(String(reflecting: type)) registered sync successfully")
    }

    @inlinable @inline(__always)
    public func register<T: Sendable>(
        _ type: T.Type,
        lifecycle: Lifecycle = .transient,
        withReplacement: Bool = false,
        resolver: @escaping () async -> T
    ) {
        let key = key(of: type)

        guard withReplacement
                || self.mapForAsync[key] == nil else {
            fatalError("failed to register \(String(reflecting: type)), already registered")
        }

        lock.withLock {
            self.mapForAsync[key] = switch lifecycle {
                case .container: AsyncContainerResolver(build: resolver)
                case .transient: AsyncTransientResolver(build: resolver)
            }
        }

        logger.send("type: \(String(reflecting: type)) registered async successfully")
    }
}

// getters
extension IoC {
    @inlinable @inline(__always)
    public func get<T>(by type: T.Type) -> T? {
        let key = key(of: type)

        let instance: T? = switch self.mapForSync[key] {
            case let .some(resolver): resolver.instance() as? T
            case.none: switch self.mapForAsync[key] {
                case .none: .none
                case .some:
                    fatalError("type \(String(reflecting: type)) is registered as async, but sync access is attempted")
            }
        }

        switch instance {
            case .none:
                logger.send("no instance of \(String(reflecting: type)) registered for sync")
            case let .some(val):
                switch val as? AnyObject {
                    case .none:
                        logger.send("instance of \(String(reflecting: type)) sync resolved successfully")

                    case let .some(obj):
                        logger.send("instance of \(String(reflecting: type)) with id: \(ObjectIdentifier(obj)) sync resolved successfully")
                }
        }

        return instance

    }

    @inlinable @inline(__always)
    public func getAsync<T>(by type: T.Type) async -> T? {
        let key = key(of: type)

        let instance: T? = switch self.mapForAsync[key] {
            case let .some(resolver): await resolver.instance() as? T
            case .none: switch self.mapForSync[key] {
                case let .some(resolver): resolver.instance() as? T
                case .none: .none
            }
        }

        switch instance {
            case .none:
                logger.send("no instance of \(String(reflecting: type)) registered for async")
            case let .some(val):
                switch val as? AnyObject {
                    case .none:
                        logger.send("instance of \(String(reflecting: type)) async resolved successfully")

                    case let .some(obj):
                        logger.send("instance of \(String(reflecting: type)) with id: \(ObjectIdentifier(obj)) async resolved successfully")
                }
        }

        return instance
    }

    @inlinable @inline(__always)
    public func waitForResolve<T>(_ type: T.Type) async -> T {
        while true {
            switch await getAsync(by: type) {
                case .none: await Task.yield()
                case let .some(relux): return relux
            }
        }
    }
}
