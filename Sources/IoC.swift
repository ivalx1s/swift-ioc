public final class IoC {
    public typealias Key = ObjectIdentifier

    @usableFromInline
    internal private(set)
    var mapForSync: [Key: any SyncResolver] = [:]

    @usableFromInline
    internal private(set)
    var mapForAsync: [Key: any AsyncResolver] = [:]

    @inlinable @inline(__always)
    public init() {}
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
            fatalError("failed to register \(type), already registered")
        }

        self.mapForAsync[key] = switch lifecycle {
            case .container: AsyncContainerResolver(build: resolver)
            case .transient: AsyncTransientResolver(build: resolver)
        }
    }

    @inlinable @inline(__always)
    func get<T>(by type: T.Type) -> T? {
        switch self.mapForSync[key(of: type)]?.instance() {
            case .none: .none
            case let .some(inst): inst as? T
        }
    }

    @inlinable @inline(__always)
    func get<T>(by type: T.Type) async -> T? {
        let key = key(of: type)

        return switch self.mapForSync[key]?.instance() {
            case let .some(inst): inst as? T
            case .none: switch self.mapForAsync[key] {
                case .none: .none
                case let .some(resolver): await resolver.instance() as? T
            }
        }
    }
}
