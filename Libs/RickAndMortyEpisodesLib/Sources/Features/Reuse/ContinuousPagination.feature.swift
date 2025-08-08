import Foundation

/// Namespace for the ContinuousPagination feature. Serves as an anchor for project navigation.
enum ContinuousPaginationFeature<
  Input: Equatable & Sendable,
  Item: Equatable & Sendable & Codable & Identifiable
> {
  enum Deps {
    typealias Page = ResponsePageContainer<Item>
    typealias PageLoading = ProcessHostFeature<Input, Page>
    typealias PageLoadingContinuation = CheckedContinuation<Page, Error>
    typealias GetPage = @Sendable (Input) async throws -> Page
    typealias GetNextInput = @Sendable (Page) -> Input?
    typealias IsPageFirst = @Sendable (Page) -> Bool
  }
}
