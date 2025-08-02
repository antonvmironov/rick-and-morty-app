import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the BaseCharacter feature. Serves as an anchor for project navigation.
enum BaseCharacterFeature {
  static func previewCharacter() -> CharacterDomainModel {
    return .dummy
  }
}
