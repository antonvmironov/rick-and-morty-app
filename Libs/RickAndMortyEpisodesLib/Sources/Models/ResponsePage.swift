import Foundation

struct ResponsePage<Element: Sendable & Codable>: Sendable, Codable {
  var info: ResponsePageInfo
  var results: [Element]
}

struct ResponsePageInfo: Sendable, Codable {
  var count: Int
  var pages: Int
  var next: URL?
  var prev: URL?
}
