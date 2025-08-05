import BackgroundTasks
import Foundation

actor BackgroundRefresher: Sendable {
  let networkGateway: NetworkGateway

  init(networkGateway: NetworkGateway) {
    self.networkGateway = networkGateway
  }

  func register() {
    let bundleID =
      Bundle.main.bundleIdentifier ?? "me.amyronov.rnm-demo.RickAndMortyApp"
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: "\(bundleID).refresh",
      using: nil
    ) { task in
      Task {
        await self.handle(task: task)
      }
    }
  }

  func scheduleRefreshing<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>,
    id: String
  ) {
    // TBD
  }

  func handle(task: BGTask) async {
    // TBD

  }
}
