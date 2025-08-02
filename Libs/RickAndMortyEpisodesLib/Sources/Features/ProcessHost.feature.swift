import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the ProcessHost feature. Serves as an anchor for project navigation.
enum ProcessHostFeature {
  // constants and shared functions go here

  static func processEffect<Input, Output>(
    input: Input,
    operation: @escaping @Sendable (Input) async throws -> Output,
    send: Send<ProcessHostAction<Input, Output>>
  ) async {
    do {
      let result = try await operation(input)
      await send(.finishProcessing(result))
    } catch {
      await send(.failedProcessing(message: "\(error)"))
    }
  }
}

typealias ProcessHostStore<Input: Equatable, Output: Equatable> = StoreOf<
  ProcessHostReducer<Input, Output>
>
typealias ProcessHostTestStore<Input: Equatable, Output: Equatable> =
  TestStoreOf<ProcessHostReducer<Input, Output>>

extension ProcessHostStore {
  static func preview<
    Input: Equatable & Sendable,
    Output: Equatable & Sendable
  >(
    operation: @escaping @Sendable (Input) async throws -> Output
  ) -> ProcessHostStore<Input, Output> {
    return initial(operation: operation)
  }

  static func initial<
    Input: Equatable & Sendable,
    Output: Equatable & Sendable
  >(
    operation: @escaping @Sendable (Input) async throws -> Output
  ) -> ProcessHostStore<Input, Output> {
    let state = ProcessHostState<Input, Output>()
    return ProcessHostStore(
      initialState: state,
      reducer: {
        ProcessHostReducer(operation: operation)
      }
    )
  }
}

@Reducer
struct ProcessHostReducer<
  Input: Equatable & Sendable,
  Output: Equatable & Sendable
> {
  typealias State = ProcessHostState<Input, Output>
  typealias Action = ProcessHostAction<Input, Output>

  let operation: @Sendable (Input) async throws -> Output

  var body: some ReducerOf<Self> {
    processingReducer
  }

  private var processingReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch (state.status, action) {
      case (.idle(let previousSuccess, _), .process(let input)):
        state.status = .processing(
          previousSuccess: previousSuccess,
          input: input
        )
        let operation = self.operation
        return .run { send in
          await ProcessHostFeature.processEffect(
            input: input,
            operation: operation,
            send: send
          )
        }.cancellable(id: "process-operation")
      case (.processing, .finishProcessing(let result)):
        state.status = .idle(previousSuccess: result, previousFailure: nil)
        return .none
      case (.processing(let previousSuccess, _), .failedProcessing(let message)):
        state.status = .idle(
          previousSuccess: previousSuccess,
          previousFailure: message
        )
        return .none
      default:
        return .none
      }
    }
  }
}

@ObservableState
struct ProcessHostState<Input: Equatable, Output: Equatable>: Equatable {
  var status: ProcessHostStatus<Input, Output> = .idle(
    previousSuccess: nil,
    previousFailure: nil
  )

  static func initial() -> Self {
    return .init()
  }
}

@CasePathable
enum ProcessHostAction<
  Input: Equatable & Sendable,
  Output: Equatable & Sendable
>: Sendable, Equatable {
  case process(Input)
  case finishProcessing(Output)
  case failedProcessing(message: String)
}

enum ProcessHostStatus<Input: Equatable, Output: Equatable>: Equatable {
  case idle(previousSuccess: Output?, previousFailure: String?)
  case processing(previousSuccess: Output?, input: Input)

  var success: Output? {
    switch self {
    case .idle(let previousSuccess, _):
      return previousSuccess
    case .processing(let previousSuccess, _):
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
