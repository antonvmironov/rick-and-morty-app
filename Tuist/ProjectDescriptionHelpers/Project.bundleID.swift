import ProjectDescription

extension Project {
  static func appBundleID(name: String) -> String {
    "me.amyronov.rnm-demo.\(name).app"
  }

  static func libraryBundleID(
    name: String,
    product: Product,
  ) -> String {
    "me.amyronov.rnm-demo.\(name).\(product)"
  }

  static func testsBundleID(name: String) -> String {
    "me.amyronov.rnm-demo.\(name).tests"
  }
}

let destinations: Destinations = Destinations()
  .union(Destinations.iOS)
