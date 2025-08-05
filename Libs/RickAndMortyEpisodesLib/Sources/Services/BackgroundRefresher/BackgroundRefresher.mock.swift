import BackgroundTasks
import Foundation

struct MockBackgroundRefresher: BackgroundRefresher {
  init() { /* no-op */  }
  func register() { /* no-op */  }
  func scheduleRefreshing<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>,
    id: RefreshOperationID
  ) { /* no-op */  }
  func simulateSending() { /* no-op */  }
}
