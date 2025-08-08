import ComposableArchitecture
import Foundation

extension CharacterBriefFeature {
  @Observable final class ProdViewModel: FeatureViewModel {
    let id: ID
    private let store: BaseCharacterFeature.FeatureStore

    init(store: BaseCharacterFeature.FeatureStore) {
      self.id = store.characterIDString
      self.store = store
    }

    var displayCharacter: CharacterDomainModel {
      store.actualCharacter ?? store.placeholderCharacter
    }
    var isPlaceholder: Bool {
      store.characterLoading.status.success == nil
    }
    var isShimmering: Bool {
      store.characterLoading.status.isProcessing
    }
    var characterURL: URL {
      store.characterURL
    }
    var characterIDString: String {
      characterURL.lastPathComponent
    }
    var characterLoadingSuccess: CharacterDomainModel? {
      store.characterLoading.status.success
    }
    var characterLoadingFailureMessage: String? {
      store.characterLoading.status.failureMessage
    }
    func preloadIfNeeded() {
      store.send(.preloadIfNeeded)
    }
    func reloadOnFailure() {
      store.send(.reloadOnFailure)
    }
  }
}
