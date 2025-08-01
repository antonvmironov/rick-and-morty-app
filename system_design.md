# System Design

## Deliverables

- Current Git repository
- iOS app built from the repository and achieving the goals of [the assignment](./assignment.md)
- Automated tests covering the app

## Design Choices

- [Tuist](https://tuist.dev) as the build toolset
- [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) as the backbone of main actor logic management
- [SwiftUI](https://developer.apple.com/swiftui/) as the backbone of user experience

## Module Organization

- `RickAndMortyApp` for the app deliverable, declared as an app target in Tuist
- `RickAndMortyEpisodesModule` for **a feature module**, declared as a library target in Tuist. This module contains all the features from [the assignment](./assignment.md) including episodes list (`EpisodeList.feature.swift`), episode details (`EpisodeDetails.feature.swift`), character details (`CharacterDetails.feature.swift`), etc. With a `RickAndMortyService` coordinating
    - network communication through `RickAndMortyNetworkGateway` connected to the [API](https://rickandmortyapi.com/documentation/#rest)
    - persistence through SwiftData
    - validation, error handling, etc
- (placeholder) `SharedModule` for a utility module containing reusable primitives, extensions, etc.

Each module consists of source files intended to be compiled for release, assets, tests, etc.
Like any module, feature modules declare protocols, types, and functions. Unlike other modules, feature modules have a special organizational structure.
Each **feature module consists of one or more software components**, which are cohesive collections of features.
Additionally, feature modules include several types of **service layers** responsible for non-main actor activities: asynchronous computation, persistence, networking, etc.

### Special File Types

To improve code organization and clarity, the project uses special file naming conventions:

- `*.feature.swift`: These files contain the main implementation for a specific feature, such as UI, state, actions, and reducers. For example, `EpisodeList.feature.swift` defines the episode list feature’s view, state, actions, and reducer in a single, cohesive file.
- `*.tests.swift`: These files contain unit tests for the corresponding feature or module. For example, `RickAndMortyEndpoints.tests.swift` contains tests for the endpoints and networking logic.
- `*.model.swift`: These files declare model variants that represent a given entity. See [Model Variants](#model-variants)

### Type Naming Patterns

#### Features
- `MySubjectFeature`: A namespace for shared functionality across types in this feature, and a central point for navigation.
- `MySubjectView`: The `SwiftUI` view representing this feature.
- `MySubjectStore`: A typealias for a swift-composable-architecture store specialized with `MySubjectReducer`.
- `MySubjectReducer`: The implementation of a swift-composable-architecture reducer, specialized with `MySubjectState` and `MySubjectAction`.
- `MySubjectState`: The main actor-isolated state for this feature, including UI, navigation, and business logic. Business state should focus on validation and UX process control, while complex tasks such as computation, I/O, and persistence should be delegated to a service layer.
- `MySubjectAction`: (To be defined) Actions associated with this feature.

#### Model Variants
- `MySubjectDomainModel`: A model representing the canonical form of a subject as used within the application's core logic. It is a pure value type, conforming to Codable, Equatable, and Sendable, and is decoupled from storage, and UI-specific concerns.

## Main Actor Organization

The `SwiftUI` app (`struct RickAndMortyApp: App`) is the entry point to the application. It coordinates high-level responsibilities including:
- Managing the root `Store` of the composable architecture
- Dependency injection setup
- Setting up a composition of features

 SwiftUI and Swift Composable Architecture are used to implement, coordinate, and compose features.
Features consist of:
- **A view** declared as `struct MyFeatureView: SwiftUI.View`, responsible for declaring the UI hierarchy, observing state changes, and sending actions on user input
- **A store** declared as `typealias MyFeatureStore = StoreOf<MyFeatureReducer>`, responsible for state management, action processing, and effect scheduling. It is part of a hierarchy of stores, with the root store owned by the `SwiftUI` app, and is responsible for delegating responsibilities to nested stores.
- **A reducer** declared as `@Reducer struct MyFeatureReducer`. This is a declaration of the store's behavior. It reacts to actions by reading and mutating state and scheduling effects. Dependencies are injected into reducers.
- **A state** declared as `struct MyFeatureState`. This represents the state of the UI and main actor business logic.
- **An action** declared as `enum MyFeatureAction`. Each action sent to a store is processed through the reducer.

### On Composable Architecture
[swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) is subject to valid criticisms.
It has a steep learning curve, performance pitfalls, and encapsulation issues. Yet, it is still a very powerful tool for organizing state management, action processing, and effect scheduling. A good starting point for a small to medium scale application with numerous escape hatches useful for addressing pitfalls that become frustrating at the larger scale.
