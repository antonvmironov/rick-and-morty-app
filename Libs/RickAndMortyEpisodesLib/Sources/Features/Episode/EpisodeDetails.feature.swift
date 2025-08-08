import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeDetails feature. Serves as an anchor for project navigation.
enum EpisodeDetailsFeature {
  enum Deps {
    typealias Episode = EpisodeDomainModel
    typealias Character = CharacterDomainModel
    typealias BaseEpisode = BaseEpisodeFeature
    typealias BaseCharacter = BaseCharacterFeature
    typealias CharacterState = BaseCharacter.FeatureState
    typealias CharacterStatesArray = IdentifiedArrayOf<CharacterState>
    typealias CharacterBrief = CharacterBriefFeature
    typealias CharacterDetails = CharacterDetailsFeature
  }
}
