import ProjectDescription

func makeSchemes(
  name: String,
  testPlans: [Path],
) -> [Scheme] {
  let targetRef = TargetReference(stringLiteral: name)
  let testAction = TestAction.testPlans(testPlans)
  let buildAction = BuildAction.buildAction(targets: [targetRef])
  let runAction = RunAction.runAction(
    diagnosticsOptions: .options(mainThreadCheckerEnabled: true)
  )
  let appScheme = Scheme.scheme(
    name: name,
    shared: false,
    hidden: false,
    buildAction: buildAction,
    testAction: testAction,
    runAction: runAction
  )
  return [appScheme]
}
