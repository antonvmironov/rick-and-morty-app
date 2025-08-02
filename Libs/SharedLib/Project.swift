import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.lib(
  name: "SharedLib",
  product: .staticLibrary,
  dependencies: [
    .external(name: "ComposableArchitecture")
  ],
  testPlans: ["Fixtures/SharedLib.xctestplan"],
)
