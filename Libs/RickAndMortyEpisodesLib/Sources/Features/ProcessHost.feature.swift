import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the ProcessHost feature. Serves as an anchor for project navigation.
enum ProcessHostFeature<Input: Equatable & Sendable, Output: Equatable> {
  // constants and shared functions go here
  typealias FeatureStore = StoreOf<FeatureReducer>
  static func processEffect(
    input: Input,
    operation: @escaping @Sendable (Input) async throws -> Output,
    send: Send<FeatureAction>
  ) async {
    do {
      let result = try await operation(input)
      await send(.finishProcessing(result))
    } catch {
      await send(.failedProcessing(message: "\(error)"))
    }
  }

  @MainActor
  static func previewStore(
    operation: @escaping @Sendable (Input) async throws -> Output
  ) -> FeatureStore {
    return initialStore(operation: operation)
  }

  @MainActor
  static func initialStore(
    operation: @escaping @Sendable (Input) async throws -> Output
  ) -> FeatureStore {
    return FeatureStore(
      initialState: FeatureState(),
      reducer: {
        FeatureReducer(operation: operation)
      }
    )
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

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
          return .run { [operation] send in
            await ProcessHostFeature.processEffect(
              input: input,
              operation: operation,
              send: send
            )
          }.cancellable(id: "process-operation")
        case (.processing, .finishProcessing(let result)):
          state.status = .idle(previousSuccess: result, previousFailure: nil)
          return .none
        case (
          .processing(let previousSuccess, _), .failedProcessing(let message)
        ):
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
  struct FeatureState: Equatable {
    var status: FeatureStatus = .idle(
      previousSuccess: nil,
      previousFailure: nil
    )

    static func initial() -> Self {
      return .init()
    }
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case process(Input)
    case finishProcessing(Output)
    case failedProcessing(message: String)
  }

  enum FeatureStatus: Equatable {
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

    var failureMessage: String? {
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
}
