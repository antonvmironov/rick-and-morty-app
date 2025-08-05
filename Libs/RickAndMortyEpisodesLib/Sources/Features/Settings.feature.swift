import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

enum SettingsFeature: Feature {
  @MainActor
  static func previewStore() -> FeatureStore {
    FeatureStore(
      initialState: .init(),
      reducer: { FeatureReducer() }
    )
  }

  struct FeatureView: View {
    @Bindable var store: FeatureStore

    var body: some View {
      List {
        LabeledContent("Version", value: store.version)
        aboutSection
        debugSection
        cacheSection
      }
      .listStyle(.plain)
      .navigationTitle("Settings")
    }

    private var aboutSection: some View {
      Section(
        content: {
          Text(
            """
            Good day to you!

            This is a Rick and Morty demo app.
            Built by Anton Myronov
            """
          )
        },
        header: {
          Text("About")
        }
      )
    }

    private var debugSection: some View {
      Section(
        content: {
          LabeledContent("Background Fetch") {
            Button(
              action: {
                store.send(.simulateBackgroundRefresh)
              },
              label: {
                Label(
                  title: { Text("Simulate") },
                  icon: { Image(systemName: "figure.run") }
                )
              }
            )
          }
        },
        header: {
          HStack {
            Text("Debug Settings")
            Spacer()
          }
        }
      )
    }

    private var cacheSection: some View {
      Section(
        content: {
          ForEach(store.cacheReports) { report in
            cacheReportView(report: report)
          }
        },
        header: {
          HStack {
            Text("Cache Settings")
            Spacer()
            Button(
              action: {
                store.send(.updateCacheReports)
              },
              label: {
                Label(
                  title: {
                    Text("Reload")
                  },
                  icon: {
                    Image(
                      systemName:
                        "arrow.trianglehead.2.counterclockwise.rotate.90"
                    )
                  }
                )
              }
            )
          }
        }
      )
    }

    private func cacheReportView(report: URLCacheReport) -> some View {
      Group {
        HStack {
          Text("\(report.category) cache")
          Spacer(minLength: UIConstants.space)
          Button(
            action: {
              store.send(.clearCache(report.category))
            },
            label: {
              Label(
                title: {
                  Text("Clear")
                },
                icon: {
                  Image(systemName: "clear.fill")
                }
              )
            }
          )
        }
        LabeledContent(
          "RAM used",
          value: report.currentMemoryUsage,
          format: .byteCount(style: .memory)
        )
        LabeledContent(
          "RAM max",
          value: report.memoryCapacity,
          format: .byteCount(style: .memory)
        )
        LabeledContent(
          "disk used",
          value: report.currentDiskUsage,
          format: .byteCount(style: .file)
        )
        LabeledContent(
          "disk max",
          value: report.diskCapacity,
          format: .byteCount(style: .file)
        )
      }
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    @Dependency(\.urlCacheFactory)
    var urlCacheFactory: URLCacheFactory

    @Dependency(\.backgroundRefresher)
    var backgroundRefresher: BackgroundRefresher

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .updateCacheReports:
          state.cacheReports = urlCacheFactory.allReports()
          return .none
        case .simulateBackgroundRefresh:
          return .run { _ in
            await backgroundRefresher.simulateSending()
          }
        case .clearCache(let category):
          urlCacheFactory.clearCache(category: category)
          return .none
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var version: String =
      (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
      ?? "unknown"

    var cacheReports = [URLCacheReport]()
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case updateCacheReports
    case simulateBackgroundRefresh
    case clearCache(URLCacheCategory)
  }
}

#Preview {
  NavigationStack {
    SettingsFeature.FeatureView(store: SettingsFeature.previewStore())
  }
}
