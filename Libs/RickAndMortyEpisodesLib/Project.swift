import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.lib(
  name: "RickAndMortyEpisodesLib",
  product: .staticLibrary,
  dependencies: [
    .external(name: "ComposableArchitecture")
  ],
  testPlans: ["Fixtyres/RickAndMortyEpisodesLib.xctestplan"],
)
