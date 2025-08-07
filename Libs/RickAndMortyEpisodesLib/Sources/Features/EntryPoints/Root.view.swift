import Foundation
import SharedLib
import SwiftUI

/// Namespace for the RootFeature feature. Serves as an anchor for project navigation.
extension RootFeature {
  @MainActor protocol FeatureViewModel: AnyObject, Observable {
    associatedtype EpisodesRootViewModel: Deps.EpisodesRoot.FeatureViewModel
    associatedtype SettingsViewModel: Deps.Settings.FeatureViewModel
    var episodesRoot: EpisodesRootViewModel { get }
    var settingsViewModel: SettingsViewModel { get }
    var isSettingsPresented: Bool { get set }
    func preloadIfNeeded(
      onRefresh: @escaping @MainActor @Sendable () -> Void
    )
    func didRefresh()
    func toggleSettingsPresentation()
  }

  enum A11yIDs: String, A11yIDProvider {
    case navTitle = "nav-title"
    case enterSettingsButton = "enter-settings-button"
    case exitSettingsButton = "escape-settings-button"
    var a11yID: String { rawValue }
  }

  struct FeatureView<ViewModel: FeatureViewModel>: View {
    @Bindable
    var viewModel: ViewModel

    init(viewModel: ViewModel) {
      self.viewModel = viewModel
    }

    var body: some View {
      EpisodesRootFeature.FeatureView(viewModel: viewModel.episodesRoot)
        .a11yID(A11yIDs.navTitle)
        .onAppear {
          viewModel.preloadIfNeeded { [weak viewModel] in
            viewModel?.didRefresh()
          }
        }
        .toolbar {
          ToolbarItem {
            toggleSettingsPresentedButton(
              title: "Settings",
              iconSystemName: "figure.walk"
            )
            .padding(UIConstants.space)
            .a11yID(A11yIDs.enterSettingsButton)
          }
        }
        .sheet(isPresented: $viewModel.isSettingsPresented) {
          NavigationStack {
            SettingsFeature.FeatureView(viewModel: viewModel.settingsViewModel)
          }
          .overlay(alignment: .topTrailing) {
            toggleSettingsPresentedButton(
              title: "Back",
              iconSystemName: "escape"
            )
            .a11yID(A11yIDs.exitSettingsButton)
            .padding(UIConstants.space)
          }
        }
    }

    private func toggleSettingsPresentedButton(
      title: String,
      iconSystemName: String
    ) -> some View {
      Button(
        action: {
          viewModel.toggleSettingsPresentation()
        },
        label: {
          Label(
            title: {
              Text(title)
            },
            icon: {
              Image(systemName: iconSystemName)
            }
          ).labelStyle(.iconOnly)
        }
      )
      .buttonStyle(.bordered)
      .accessibilityAction {
        viewModel.toggleSettingsPresentation()
      }
    }
  }

  final class MockViewModel: FeatureViewModel {
    typealias EpisodesRootViewModel = Deps.EpisodesRoot.MockViewModel
    typealias SettingsViewModel = Deps.Settings.MockViewModel
    var episodesRoot: EpisodesRootViewModel = .preview()
    var settingsViewModel: SettingsViewModel = .init()
    var isSettingsPresented: Bool = false
    func preloadIfNeeded(onRefresh: @escaping @MainActor @Sendable () -> Void) {
      /* no-op*/
    }
    func didRefresh() {
      /* no-op*/
    }
    func toggleSettingsPresentation() {
      /* no-op*/
    }
  }
}

private typealias Subject = RootFeature
#Preview {
  @Previewable @State var viewModel = Subject.MockViewModel()
  NavigationStack {
    Subject.FeatureView(viewModel: viewModel)
      .navigationTitle("Test Episode List")
  }
}
