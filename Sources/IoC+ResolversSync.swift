import Foundation

extension IoC {
    public final class SyncContainerResolver<T>: SyncResolver {
        private let lock = NSLock()
        private var _instance: T?
        private let build: () -> T

        public init(build: @escaping () -> T) {
            self.build = build
        }

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
        private let build: () -> T

        public init(build: @escaping () -> T) {
            self.build = build
        }

        public func instance() -> T { self.build() }
    }
}
