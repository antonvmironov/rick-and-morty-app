import BackgroundTasks
import Foundation

actor ProdBackgroundRefresher: BackgroundRefresher {
  let networkGateway: NetworkGateway
  var refreshOperationsByID = [RefreshOperationID: RefreshOperation]()
  let backgroundTaskID: String
  nonisolated var scheduler: BGTaskScheduler { .shared }
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

  nonisolated func register() {
    scheduler.register(
      forTaskWithIdentifier: backgroundTaskID,
      using: nil
    ) { [self] task in
      self.handle(task: task)
    }

    Task {
      await scheduleNextRefresh()
    }
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
      print("Scheduled background task \(backgroundTaskID)")
    } catch {
      print(
        """
          [ERROR] failed to schedule a task \(backgroundTaskID).
          Error: \(error)
        """
      )
    }
  }

  nonisolated private func handle(task: BGTask) {
    let operation = Task {
      var success = false
      defer {
        task.setTaskCompleted(success: success)
      }
      guard task.identifier == backgroundTaskID else {
        return
      }
      success = await self.refresh()
    }
    task.expirationHandler = {
      print("[Error] my task has expired")
      operation.cancel()
    }
  }

  private func refresh() async -> Bool {
    let refreshOperations = refreshOperationsByID.values
    for refreshOperation in refreshOperations where !Task.isCancelled {
      try? await refreshOperation(networkGateway)
    }
    scheduleNextRefresh()
    return true
  }
}

extension BGTask: @unchecked @retroactive Sendable {
  /* to call completion async */
}
