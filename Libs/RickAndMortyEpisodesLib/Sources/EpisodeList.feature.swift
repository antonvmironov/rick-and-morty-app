import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
public enum EpisodeListFeature {
  // constants and shared functions go here
}

public struct EpisodeListView: View {
  @Bindable var store: EpisodeListStore

  public init(store: EpisodeListStore) {
    self.store = store
  }

  public var body: some View {
    Button(
      action: {
        store.send(.increment)
      },
      label: {
        Text("counter is \(store.counter)")
      }
    )
    .tag("Increment")
  }
}

#Preview {
  EpisodeListView(store: EpisodeListStore.preview())
}

public typealias EpisodeListStore = StoreOf<EpisodeListReducer>
public typealias EpisodeListTestStore = TestStoreOf<EpisodeListReducer>

extension EpisodeListStore {
  static func preview() -> EpisodeListStore {
    return initial()
  }

  public static func initial() -> EpisodeListStore {
    let state = EpisodeListState()
    return EpisodeListStore(initialState: state) {
      EpisodeListReducer()
    }
  }
}

@Reducer
public struct EpisodeListReducer {
  public typealias State = EpisodeListState
  public typealias Action = EpisodeListAction
  public var body: some ReducerOf<Self> {
    incrementingReducer
  }

  private var incrementingReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .increment:
        state.counter += 1
        return .none
      }
    }
  }
}

@ObservableState
public struct EpisodeListState: Equatable {
  public var counter = 0
}

@CasePathable
public enum EpisodeListAction: Equatable {
  case increment
}
