import BackgroundTasks
import Foundation

struct MockBackgroundRefresher: BackgroundRefresher {
  init() { /* no-op */  }
  func register() { /* no-op */  }
  func scheduleRefreshing<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>,
    id: RefreshOperationID,
    didRefresh: @escaping @Sendable () async -> Void
  ) async {
    await didRefresh()  // for testing purposes
  }
  func simulateSending() { /* no-op */  }
}
