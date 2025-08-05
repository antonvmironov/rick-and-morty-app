import ProjectDescription

extension Project {

  public static func lib(
    name: String,
    product: Product = .framework,
    dependencies: [TargetDependency] = [],
    testDependencies: [TargetDependency] = [],
    testPlans: [Path] = [],
  ) -> Project {
    var targets = [Target]()
    let libraryTarget = Target.target(
      name: name,
      destinations: destinations,
      product: product,
      bundleId: libraryBundleID(name: name, product: product),
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: dependencies
    )
    targets.append(libraryTarget)
    if !testPlans.isEmpty {
      let testTarget = Target.target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: testsBundleID(name: "\(name)Tests"),
        infoPlist: .default,
        sources: [
          "Tests/**"
        ],
        resources: ["Fixtures/**"],
        dependencies: [.target(name: name)] + testDependencies
      )
      targets.append(testTarget)
    }

    return Project(
      name: name,
      settings: .settings(
        base: [
          "SWIFT_VERSION": "6.1",
          "ENABLE_USER_SCRIPT_SANDBOXING": "1",
        ],
      ),
      targets: targets,
      schemes: makeSchemes(name: name, testPlans: testPlans),
    )
  }
}
