import Foundation

/// Namespace for the CharacterBrief feature. Serves as an anchor for project navigation.
enum CharacterBriefFeature {
  enum Deps {
    typealias Character = CharacterDomainModel
    typealias CharacterLoadingFeature = ProcessHostFeature<URL, Character>
    typealias Base = BaseCharacterFeature
    typealias SkeletonDecoration = SkeletonDecorationFeature
  }
}
