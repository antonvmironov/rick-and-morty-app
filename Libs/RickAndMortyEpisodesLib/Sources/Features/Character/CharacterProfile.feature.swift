import Foundation

/// Namespace for the BaseCharacter feature. Serves as an anchor for project navigation.
enum CharacterProfileFeature {
  enum Deps {
    typealias Character = CharacterDomainModel
    typealias SkeletonDecoration = SkeletonDecorationFeature
  }
}
