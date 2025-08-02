// swift-tools-version: 6.1
import PackageDescription

#if TUIST
  import struct ProjectDescription.PackageSettings

  let packageSettings = PackageSettings(
    productTypes: [:]
  )
#endif

let package = Package(
  name: "RickAndMorty",
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      .upToNextMinor(from: "1.21.0")
    ),
    .package(
      url: "https://github.com/tevelee/SwiftUI-Flow.git",
      .upToNextMinor(from: "3.1.0")
    ),
    .package(
      url: "https://github.com/markiv/SwiftUI-Shimmer",
      .upToNextMinor(from: "1.5.1")
    ),
    .package(
      url: "https://github.com/onevcat/Kingfisher",
      .upToNextMinor(from: "8.5.0")
    ),
  ]
)
