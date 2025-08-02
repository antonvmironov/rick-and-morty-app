import ComposableArchitecture
import Flow
import Foundation
import Kingfisher
import SharedLib
import SwiftUI

/// Namespace for the CharacterBrief feature. Serves as an anchor for project navigation.
enum CharacterBriefFeature {
  struct FeatureView: View {
    var character: CharacterDomainModel

    init(character: CharacterDomainModel) {
      self.character = character
    }

    var body: some View {
      VStack(alignment: .leading) {
        Text(character.name).font(.headline)
        HFlow {
          Group {
            Text(character.species.description)
            if !character.type.isEmpty {
              Text(character.type)
            }
          }
          .font(.body)
          .tagDecoration()
        }
      }
    }
  }
}

#Preview {
  CharacterBriefFeature.FeatureView(
    character: BaseCharacterFeature.previewCharacter()
  )
  .frame(maxWidth: .infinity)
}
