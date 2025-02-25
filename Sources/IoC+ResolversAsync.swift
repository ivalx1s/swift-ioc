import Foundation

extension IoC {
    public final class AsyncContainerResolver<T: Sendable>: AsyncResolver, Sendable {
        private let lock: AsyncLock = .init()

        nonisolated(unsafe)
        private var _instance: T?

        nonisolated(unsafe)
        private let build: () async -> T

        public init(build: @escaping () async -> T) {
            self.build = build
        }

        public func instance() async -> T {
            await lock.withLock {
                switch _instance {
                    case .none:
                        let inst = await build()
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
    public final class AsyncTransientResolver<T: Sendable>: AsyncResolver, Sendable {

        @usableFromInline
        internal let lock: AsyncLock = .init()

        @usableFromInline
        nonisolated(unsafe)
        internal let build: () async -> T

        @inlinable @inline(__always)
        public init(build: @escaping () async -> T) {
            self.build = build
        }

        @inlinable @inline(__always)
        public func instance() async -> T {
            await build()
        }
    }
}
