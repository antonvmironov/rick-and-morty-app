import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.lib(
  name: "RickAndMortyEpisodesLib",
  product: .framework,
  dependencies: [
    .external(name: "ComposableArchitecture")
  ],
  testPlans: ["Fixtures/RickAndMortyEpisodesLib.xctestplan"],
)
