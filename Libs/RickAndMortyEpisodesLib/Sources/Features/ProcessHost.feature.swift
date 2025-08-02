import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the ProcessHost feature. Serves as an anchor for project navigation.
enum ProcessHostFeature {
  // constants and shared functions go here

  static func processEffect<Output>(
    operation: @escaping @Sendable() async throws -> Output,
    send: Send<ProcessHostAction<Output>>
  ) async {
    do {
      let result = try await operation()
      await send(.finishProcessing(result))
    } catch {
      await send(.failedProcessing(message: "\(error)"))
    }
  }
}

typealias ProcessHostStore<Output: Equatable> = StoreOf<ProcessHostReducer<Output>>
typealias ProcessHostTestStore<Output: Equatable> = TestStoreOf<ProcessHostReducer<Output>>

extension ProcessHostStore {
  static func preview<Output: Equatable>(
    operation: @escaping @Sendable () async throws -> Output
  ) -> ProcessHostStore<Output> {
    return initial(operation: operation)
  }

  static func initial<Output: Equatable>(
    operation: @escaping @Sendable () async throws -> Output
  ) -> ProcessHostStore<Output> {
    let state = ProcessHostState<Output>()
    return ProcessHostStore(
      initialState: state,
      reducer: {
        ProcessHostReducer(operation: operation)
      }
    )
  }
}

@Reducer
struct ProcessHostReducer<Output: Equatable> {
  typealias State = ProcessHostState<Output>
  typealias Action = ProcessHostAction<Output>

  let operation: @Sendable () async throws -> Output

  var body: some ReducerOf<Self> {
    processingReducer
  }

  private var processingReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch (state.status, action) {
      case (.idle(previousSuccess: .none, _), .preloadIfNeeded):
        return .send(.process)
      case (.idle(let previousSuccess, _), .process):
        state.status = .processing(previousSuccess: previousSuccess)
        let operation = self.operation
        return .run { send in
          await ProcessHostFeature.processEffect(
            operation: operation,
            send: send
          )
        }.cancellable(id: "process-operation")
      case (.processing(let previousSuccess), .finishProcessing(let result)):
        state.status = .idle(previousSuccess: result, previousFailure: nil)
        return .none
      case (.processing(let previousSuccess), .failedProcessing(let message)):
        state.status = .idle(previousSuccess: previousSuccess, previousFailure: message)
        return .none
      default:
        return .none
      }
    }
  }
}

@ObservableState
struct ProcessHostState<Output: Equatable>: Equatable {
  var status: ProcessHostStatus<Output> = .idle(
    previousSuccess: nil,
    previousFailure: nil
  )

  static func initial() -> Self {
    return .init()
  }
}

@CasePathable
enum ProcessHostAction<Output: Equatable> {
  case preloadIfNeeded
  case process
  case finishProcessing(Output)
  case failedProcessing(message: String)
}

enum ProcessHostStatus<Output: Equatable>: Equatable {
  case idle(previousSuccess: Output?, previousFailure: String?)
  case processing(previousSuccess: Output?)

  var success: Output? {
    switch self {
    case .idle(let previousSuccess, _):
      return previousSuccess
    case .processing(let previousSuccess):
      return previousSuccess
    }
  }

  var failiureMessage: String? {
    switch self {
    case .idle(_, let previousFailure):
      return previousFailure
    case .processing:
      return nil
    }
  }

  var isProcessing: Bool {
    switch self {
    case .processing:
      return true
    default:
      return false
    }
  }
}
