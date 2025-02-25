import Foundation

extension IoC {
    public final class SyncContainerResolver<T>: SyncResolver {
        @usableFromInline
        internal let lock = NSLock()

        @usableFromInline
        internal var _instance: T?

        @usableFromInline
        internal let build: () -> T

        @inlinable @inline(__always)
        public init(build: @escaping () -> T) {
            self.build = build
        }

        @inlinable @inline(__always)
        public func instance() -> T {
            lock.withLock {
                switch _instance {
                    case .none:
                        let inst = build()
                        self._instance = inst
                        return inst
                    case let .some(inst):
                        return inst
                }
            }
        }
    }
}

extension IoC {
    public struct SyncTransientResolver<T>: SyncResolver {
        @usableFromInline
        internal let build: () -> T

        @inlinable @inline(__always)
        public init(build: @escaping () -> T) {
            self.build = build
        }

        @inlinable @inline(__always)
        public func instance() -> T { self.build() }
    }
}
