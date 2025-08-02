import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.lib(
  name: "RickAndMortyEpisodesLib",
  product: .framework,
  dependencies: [
    .project(
      target: "SharedLib",
      path: "//Libs/SharedLib"
    ),
  ],
  testPlans: ["Fixtures/RickAndMortyEpisodesLib.xctestplan"],
)
