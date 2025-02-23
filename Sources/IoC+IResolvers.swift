extension IoC {
    public protocol SyncResolver {
        associatedtype T
        func instance() -> T
    }
    public protocol AsyncResolver: Sendable {
        associatedtype T: Sendable
        func instance() async -> T
    }
}
