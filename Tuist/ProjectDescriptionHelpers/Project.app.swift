import ProjectDescription

extension Project {
  public static func app(
    name: String,
    dependencies: [TargetDependency] = [],
    testDependencies: [TargetDependency] = [],
    testPlans: [Path] = [],
  ) -> Project {
    var targets = [Target]()

    do {  // app target declaration
      let infoPlist: [String: Plist.Value] = [
        "CFBundleShortVersionString": "2025.07.31",
        "CFBundleVersion": "1",
        "CFBundleDisplayName": "R&M Demo",
        "UILaunchScreen": [
          "UIColorName": "",
          "UIImageName": "",
        ],
      ]

      let appTarget = Target.target(
        name: name,
        destinations: destinations,
        product: .app,
        bundleId: appBundleID(name: name),
        infoPlist: .extendingDefault(with: infoPlist),
        sources: ["Sources/**"],
        resources: ["Resources/**"],
        dependencies: dependencies
      )
      targets.append(appTarget)
    }

    if !testPlans.isEmpty {
      let testTarget = Target.target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: testsBundleID(name: "\(name)Tests"),
        infoPlist: .default,
        sources: ["Tests/**"],
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
