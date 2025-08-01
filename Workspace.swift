import ProjectDescription

let workspace = Workspace(
  name: "RickAndMorty",
  projects: [
    "Apps/**",
    "Libs/**",
  ],
  generationOptions: .options(
    enableAutomaticXcodeSchemes: false,
    renderMarkdownReadme: true,
  ),
)
