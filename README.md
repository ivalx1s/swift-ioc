# SwiftIoC Integration Guide

SwiftIoC is a lightweight dependency injection library designed to simplify dependency management in Swift applications. It helps decouple components, making code more modular and testable.

## Adding to the Project

- Integrate SwiftIoC into your project.

## Creating a Resolver with IoC Container

- Define your custom resolver using SwiftIoC.

```swift
import SwiftIoC

extension Relux {
    @MainActor
    struct Registry {
        static let ioc = IoC(logger: IoC.Logger(enabled: true))
    }
}
```

## Logger Integration

- The IoC container supports logging through the `ILogger` protocol.
- By default, logging is enabled, but it can be disabled when initializing IoC.
- A custom logger can be provided by conforming to `ILogger`.

### Example Usage

```swift
// Default instantiation with logging enabled
static let ioc = IoC()

// Disable logging
static let ioc = IoC(logger: IoC.Logger(enabled: false))

// Use a custom logger
static let ioc = IoC(logger: MyCustomLogger())
```

- To disable logging, set `enabled: false`.
- To use a custom logger, implement `ILogger` and pass it during IoC instantiation.

## Adding Resolver Accessors to the Container

- Extend the IoC container with resolver accessors.

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

## Configuring the IoC Container

- The IoC container includes a built-in logging system that can be enabled or disabled.

- You can provide a custom logger implementation when initializing the IoC container.

- Configure the IoC container with necessary dependencies.

```swift
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

## Using the Resolver to Obtain Implementations

- Use the configured IoC container to resolve and obtain implementations.

```swift
private func configureModules() async -> Relux {
    Relux.Registry.configure()
    return await Relux.Registry.resolve(Relux.self)
}
```

