import ProjectDescription

extension Project {
  public static func app(
    name: String,
    dependencies: [TargetDependency] = [],
    testDependencies: [TargetDependency] = [],
    testPlans: [Path] = [],
    hasUITests: Bool = false,
  ) -> Project {
    var targets = [Target]()

    do {  // app target declaration
      let bundleId = appBundleID(name: name)
      let infoPlist: [String: Plist.Value] = [
        "CFBundleShortVersionString": "2025.08.05",
        "CFBundleVersion": "1",
        "CFBundleDisplayName": "R&M Demo",
        "UISupportedInterfaceOrientations": [
          "UIInterfaceOrientationPortrait"
        ],
        "UIBackgroundModes": ["fetch"],
        "BGTaskSchedulerPermittedIdentifiers": [
          "\(bundleId).refresh"
        ],
        "UILaunchScreen": [
          "UIColorName": "Background",
          "UIImageName": "logo.png",
          "UIImageRespectsSafeAreaInsets": "1",
        ],
      ]

      let appTarget = Target.target(
        name: name,
        destinations: destinations,
        product: .app,
        bundleId: bundleId,
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
        sources: [
          "Tests/**",
          "../../TestsSupport/**",
        ],
        resources: ["Fixtures/**"],
        dependencies: [.target(name: name)] + testDependencies
      )
      targets.append(testTarget)
    }

    if hasUITests {
      let uiTestTarget = Target.target(
        name: "\(name)UITests",
        destinations: destinations,
        product: .uiTests,
        bundleId: testsBundleID(name: "\(name)UITests"),
        infoPlist: .default,
        sources: [
          "UITests/**",
          "../../TestsSupport/**",
        ],
        resources: ["Fixtures/**"],
        dependencies: [.target(name: name)] + testDependencies
      )
      targets.append(uiTestTarget)
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
