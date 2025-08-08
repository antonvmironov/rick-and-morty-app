import Foundation

/// Namespace for the CharacterBrief feature. Serves as an anchor for project navigation.
enum CharacterBriefFeature {
  typealias CharacterLoadingFeature = ProcessHostFeature<
    URL, CharacterDomainModel
  >
}
