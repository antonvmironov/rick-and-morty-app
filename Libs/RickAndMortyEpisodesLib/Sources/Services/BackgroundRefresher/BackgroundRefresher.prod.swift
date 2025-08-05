import BackgroundTasks
import Foundation

actor ProdBackgroundRefresher: BackgroundRefresher {
  let networkGateway: NetworkGateway
  var refreshOperationsByID = [RefreshOperationID: RefreshOperation]()
  let backgroundTaskID: String
  var scheduler: BGTaskScheduler { .shared }
  static private let refreshtimeInterval: TimeInterval = 30 * 60  // 30 minutes

  init(networkGateway: NetworkGateway) {
    self.networkGateway = networkGateway
    let bundleID =
      Bundle.main.bundleIdentifier
      ?? "me.amyronov.rnm-demo.RickAndMortyApp.app"
    self.backgroundTaskID = "\(bundleID).refresh"
  }

  func simulateSending() {
    #if DEBUG
      let selector = NSSelectorFromString(
        "_simulateLaunchForTaskWithIdentifier:"
      )
      let schedulerObj = scheduler as AnyObject
      if schedulerObj.responds(to: selector) {
        _ = schedulerObj.perform(selector, with: backgroundTaskID)
      } else {
        print(
          "[ERROR] BGTaskScheduler does not respond to _simulateLaunchForTaskWithIdentifier:"
        )
      }
    #endif
  }

  func register() {
    scheduler.register(
      forTaskWithIdentifier: backgroundTaskID,
      using: nil
    ) { task in
      Task {
        await self.handle(task: task)
      }
    }

    scheduleNextRefresh()
  }

  func scheduleRefreshing<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>,
    id: RefreshOperationID
  ) {
    refreshOperationsByID[id] = { networkGateway in
      try await networkGateway.refresh(operation: operation)
    }
  }

  private func scheduleNextRefresh() {
    let taskRequest = BGAppRefreshTaskRequest(identifier: backgroundTaskID)
    taskRequest.earliestBeginDate = Date().addingTimeInterval(
      Self.refreshtimeInterval
    )
    do {
      try scheduler.submit(taskRequest)
    } catch {
      print("[ERROR] failed to schedule a task \(error)")
    }

    print("Scheduled background task \(backgroundTaskID)")
  }

  private func handle(task: BGTask) async {
    var success = false
    defer {
      task.setTaskCompleted(success: success)
    }
    guard task.identifier == backgroundTaskID else {
      return
    }
    let refreshOperations = refreshOperationsByID.values
    for refreshOperation in refreshOperations where !Task.isCancelled {
      try? await refreshOperation(networkGateway)
    }
    success = true
    scheduleNextRefresh()
  }
}
