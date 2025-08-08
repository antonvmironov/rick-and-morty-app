import Foundation
import SharedLib
import SwiftUI

extension SettingsFeature {
  @MainActor protocol FeatureViewModel: AnyObject, Observable {
    var version: String { get }
    var cacheReports: [URLCacheReport] { get }
    func simulateBackgroundRefresh()
    func updateCacheReports()
    func clearCache(category: URLCacheCategory)
  }

  struct FeatureView<ViewModel: FeatureViewModel>: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
      List {
        LabeledContent("Version", value: viewModel.version)
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
                viewModel.simulateBackgroundRefresh()
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
          ForEach(viewModel.cacheReports) { report in
            cacheReportView(report: report)
          }
        },
        header: {
          HStack {
            Text("Cache Settings")
            Spacer()
            Button(
              action: {
                viewModel.updateCacheReports()
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
              viewModel.clearCache(category: report.category)
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

  @Observable final class MockViewModel: FeatureViewModel {
    init(
      version: String = "preview-version",
      cacheReports: [URLCacheReport] = [],
    ) {
      self.version = version
      self.cacheReports = cacheReports
    }

    // MARK: - FeatureViewModel
    let version: String
    let cacheReports: [URLCacheReport]
    func simulateBackgroundRefresh() { /* no-op */  }
    func updateCacheReports() { /* no-op */  }
    func clearCache(category: URLCacheCategory) { /* no-op */  }
  }

  @MainActor static func previewViewModel() -> MockViewModel {
    MockViewModel()
  }
}

private typealias Subject = SettingsFeature
#Preview {
  NavigationStack {
    Subject.FeatureView(viewModel: Subject.previewViewModel())
  }
}
