public final class IoC {
    public typealias Key = ObjectIdentifier

    @usableFromInline
    internal private(set)
    var mapForSync: [Key: any SyncResolver] = [:]

    @usableFromInline
    internal private(set)
    var mapForAsync: [Key: any AsyncResolver] = [:]

    @usableFromInline
    internal let logger: ILogger

    @inlinable @inline(__always)
    public init(logger: ILogger = Logger()) {
        self.logger = logger
    }
}

extension IoC {
    @inlinable @inline(__always)
    func key(of obj: Any) -> ObjectIdentifier { .init(type(of: obj)) }

    @inlinable @inline(__always)
    static func key(of type: Any.Type) -> ObjectIdentifier { .init(type) }
}

public extension IoC {
    @inlinable @inline(__always)
    func register<T>(
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

        self.mapForSync[key] = switch lifecycle {
            case .container: SyncContainerResolver(build: resolver)
            case .transient: SyncTransientResolver(build: resolver)
        }

        logger.send("type: \(String(reflecting: type)) registered sync successfully")
    }

    @inlinable @inline(__always)
    func register<T: Sendable>(
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

        self.mapForAsync[key] = switch lifecycle {
            case .container: AsyncContainerResolver(build: resolver)
            case .transient: AsyncTransientResolver(build: resolver)
        }

        logger.send("type: \(String(reflecting: type)) registered async successfully")
    }

    @inlinable @inline(__always)
    func get<T>(by type: T.Type) -> T? {
        let key = key(of: type)

        let instance: T? = switch self.mapForSync[key] {
            case let .some(resolver): resolver.instance() as? T
            case.none: switch self.mapForAsync[key] {
                case .none: .none
                case .some: fatalError("type \(String(reflecting: type)) is registered as async, but sync access is attempted")
            }
        }

        switch instance {
            case .none:
                logger.send("no instance of \(String(reflecting: type)) registered")
            case .some:
                logger.send("instance of \(String(reflecting: type)) resolved successfully")
        }

        return instance

    }

    @inlinable @inline(__always)
    func get<T>(by type: T.Type) async -> T? {
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
                logger.send("no instance of \(String(reflecting: type)) registered")
            case .some:
                logger.send("instance of \(String(reflecting: type)) resolved successfully")
        }

        return instance
    }
}
