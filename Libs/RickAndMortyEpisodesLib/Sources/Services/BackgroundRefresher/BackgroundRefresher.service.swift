import BackgroundTasks
import Foundation

protocol BackgroundRefresher: Sendable {
  typealias RefreshOperation = @Sendable (NetworkGateway) async throws -> Void
  typealias RefreshOperationID = String

  nonisolated func register()
  func scheduleRefreshing<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>,
    id: RefreshOperationID
  ) async
  func simulateSending() async
}
