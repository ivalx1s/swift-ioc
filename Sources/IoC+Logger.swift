extension IoC {
    public protocol ILogger {
        func send(_ msg: String)
    }
}

extension IoC {
    public struct Logger: ILogger {
        @usableFromInline
        internal let enabled: Bool

        @inlinable @inline(__always)
        public init(enabled: Bool = true) {
            self.enabled = enabled
        }

        @inlinable @inline(__always)
        public func send(_ msg: String) {
            guard enabled else { return }
            print("SwiftIoC: \(msg)")
        }
    }
}
