import Foundation

/// Namespace for the BaseCharacter feature. Serves as an anchor for project navigation.
enum BaseCharacterFeature {
  enum Deps {
    typealias Character = CharacterDomainModel
    typealias CharacterLoading = ProcessHostFeature<URL, Character>
  }
}
