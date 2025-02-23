# SwiftIoC Integration Guide

SwiftIoC is a lightweight dependency injection library designed to simplify the management of dependencies in Swift applications. It helps in decoupling components, making code more modular and testable.

## Adding to the Project

- Integrate SwiftIoC into your project.

## Creating a Resolver with IoC Container

- Define your custom resolver using SwiftIoC.
- Configure the IoC container.

```swift
import SwiftIoC

extension Relux {
    @MainActor
    struct Registry {
        static let ioc = IoC()

        static func configure() {
            // Relux dependencies
            ioc.register(Relux.self, lifecycle: .container, resolver: Self.buildRelux)
            ioc.register(Relux.Store.self, lifecycle: .container, resolver: Self.buildReluxStore)
            ioc.register(Relux.Logger.self, lifecycle: .container, resolver: Self.buildReluxLogger)
        }
    }
}
```

## Module Builders

```swift
extension Relux.Registry {
    static func buildRelux() async -> Relux {
        let relux = await Relux.init(
            logger: resolve(Relux.Logger.self),
            appStore: resolve(Relux.Store.self),
            rootSaga: .init()
        )
        return relux
    }

    static func buildReluxStore() -> Relux.Store {
        Relux.Store()
    }

    static func buildReluxLogger() -> Relux.Logger {
        ReluxLogger()
    }
}
```

## Adding Resolver Accessors to the Container

```swift
// Resolver
extension Relux.Registry {
    static func optionalResolve<T: Sendable>(_ type: T.Type) async -> T? where T.Type: Sendable {
        await ioc.get(by: type)
    }

    static func optionalResolve<T>(_ type: T.Type) -> T? {
        ioc.get(by: type)
    }

    static func resolve<T: Sendable>(_ type: T.Type) async -> T {
        await ioc.get(by: type)!
    }

    static func resolve<T>(_ type: T.Type) -> T {
        ioc.get(by: type)!
    }
}
```

## Using the Resolver to Obtain Implementations

```swift
private func configureModules() async -> Relux {
    Relux.Registry.configure()
    return await Relux.Registry.resolve(Relux.self)
}
```

