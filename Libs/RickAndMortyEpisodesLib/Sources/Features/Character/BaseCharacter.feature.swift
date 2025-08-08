import Foundation

/// Namespace for the BaseCharacter feature. Serves as an anchor for project navigation.
enum BaseCharacterFeature {
  enum Deps {
    typealias CharacterLoading = ProcessHostFeature<
      URL, CharacterDomainModel
    >
  }

  static func previewCharacter() -> CharacterDomainModel {
    return .dummy
  }
}
