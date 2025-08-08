import Foundation

/// Namespace for the CharacterDetails feature. Serves as an anchor for project navigation.
enum CharacterDetailsFeature {
  enum Deps {
    typealias Character = CharacterDomainModel
    typealias CharacterLoading = ProcessHostFeature<URL, Character>
    typealias Export = CharacterExportFeature
    typealias Profile = CharacterProfileFeature
    typealias Brief = BaseCharacterFeature
  }
}
