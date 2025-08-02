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
    )
  ]
)
