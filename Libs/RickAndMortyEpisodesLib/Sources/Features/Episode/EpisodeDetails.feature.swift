import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeDetails feature. Serves as an anchor for project navigation.
enum EpisodeDetailsFeature {
  typealias CharacterState = BaseCharacterFeature.FeatureState
  typealias CharacterStatesArray = IdentifiedArrayOf<CharacterState>
}
