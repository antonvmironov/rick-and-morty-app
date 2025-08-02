import Foundation

struct ResponsePagePayload<
  Element: Sendable & Codable & Equatable
>: Sendable, Codable, Equatable {
  var info: ResponsePageInfo
  var results: [Element]
}

struct ResponsePageInfo: Sendable, Codable, Equatable {
  var count: Int
  var pages: Int
  var next: URL?
  var prev: URL?
}

struct ResponsePageContainer<
  Element: Sendable & Codable & Equatable
>: Sendable, Codable, Equatable {
  var payload: ResponsePagePayload<Element>
  var cachedSince: Date?
  var pageURL: URL
}
