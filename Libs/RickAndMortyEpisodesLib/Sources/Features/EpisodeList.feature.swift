import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
enum EpisodeListFeature {
  // constants and shared functions go here
}

struct EpisodeListView: View {
  @Bindable var store: EpisodeListStore

  init(store: EpisodeListStore) {
    self.store = store
  }

  var body: some View {
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

typealias EpisodeListStore = StoreOf<EpisodeListReducer>
typealias EpisodeListTestStore = TestStoreOf<EpisodeListReducer>

extension EpisodeListStore {
  static func preview() -> EpisodeListStore {
    return initial()
  }

  static func initial() -> EpisodeListStore {
    let state = EpisodeListState()
    return EpisodeListStore(initialState: state) {
      EpisodeListReducer()
    }
  }
}

@Reducer
struct EpisodeListReducer {
  typealias State = EpisodeListState
  typealias Action = EpisodeListAction
  var body: some ReducerOf<Self> {
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
struct EpisodeListState: Equatable {
  var counter = 0
}

@CasePathable
enum EpisodeListAction: Equatable {
  case increment
}
