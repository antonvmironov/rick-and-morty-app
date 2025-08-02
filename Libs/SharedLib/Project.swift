import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.lib(
  name: "SharedLib",
  product: .staticLibrary,
  dependencies: [
    .external(name: "ComposableArchitecture"),
    .external(name: "Flow"),
    .external(name: "Kingfisher"),
    .external(name: "Shimmer"),
  ],
  testPlans: ["Fixtures/SharedLib.xctestplan"],
)
