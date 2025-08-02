import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the BaseCharacter feature. Serves as an anchor for project navigation.
enum BaseCharacterFeature {
  static func previewCharacter() -> CharacterDomainModel {
    // keep this force unwrap. its only for SwiftUI preview
    let character = try! Transformers.loadFixture(
      output: CharacterDomainModel.self,
      fixtureName: "character_rick"
    )
    return character
  }
}
