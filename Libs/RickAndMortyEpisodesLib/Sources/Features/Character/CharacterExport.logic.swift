import CoreTransferable
import Foundation
import Kingfisher
import SharedLib
import SwiftUI

extension CharacterExportFeature {
  static func transferrable(
    character: Deps.Character,
    imageManager: KingfisherManager = .shared
  ) -> TransferableCharacter {
    TransferableCharacter(character: character, imageManager: imageManager)
  }

  struct TransferableCharacter: Transferable, Equatable {
    var character: Deps.Character
    @ExcludedFromEquality
    var imageManager: KingfisherManager

    static var transferRepresentation: some TransferRepresentation {
      DataRepresentation(
        contentType: .pdf,
        exporting: { state in
          try await state.exportPDFData()
        },
        importing: { _ in
          fatalError("unexpected")
          throw CancellationError()
        }
      ).suggestedFileName { state in
        "\(state.character.name) - Rick and Morty character"
      }
    }

    @MainActor
    func exportPDFData() async throws -> Data {
      let retrievalResult =
        try await imageManager
        .retrieveImage(with: character.image)
      let imageOverride = Image(uiImage: retrievalResult.image)

      let fileManager = FileManager.default
      let fileDirectory = URL.temporaryDirectory
        .appendingPathComponent("exports", isDirectory: true)
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
      try fileManager.createDirectory(
        at: fileDirectory,
        withIntermediateDirectories: true
      )
      let fileURL =
        fileDirectory
        .appendingPathComponent("\(character.name).pdf", conformingTo: .pdf)

      let padding = UIConstants.space * 4
      let view = Deps.Profile.FeatureView(
        actualCharacter: character,
        mode: .snapshotRendering(imageOverride: imageOverride)
      )
      .padding(padding)

      ImageRenderer(content: view).render { size, context in
        // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
        var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        // 5: Create the CGContext for our PDF pages
        guard let pdf = CGContext(fileURL as CFURL, mediaBox: &box, nil) else {
          return
        }

        // 6: Start a new PDF page
        pdf.beginPDFPage(nil)

        // 7: Render the SwiftUI view data onto the page
        context(pdf)

        // 8: End the page and close the file
        pdf.endPDFPage()
        pdf.closePDF()
      }

      let data = try Data(contentsOf: fileURL)
      defer { try? fileManager.removeItem(at: fileDirectory) }
      return data
    }
  }
}
