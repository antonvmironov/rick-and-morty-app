import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
  name: "RickAndMortyApp",
  dependencies: [
    .project(
      target: "RickAndMortyEpisodesLib",
      path: "//Libs/RickAndMortyEpisodesLib"
    ),
  ],
  testPlans: [
    "Fixtures/RickAndMortyApp.xctestplan"
  ],
)
