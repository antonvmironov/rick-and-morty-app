import Foundation
import SharedLib
import SwiftUI

/// Namespace for the RootFeature feature. Serves as an anchor for project navigation.
public enum RootFeature {
  enum Deps {
    typealias Endpoints = EndpointsDomainModel
    typealias EndpointsLoading = ProcessHostFeature<URL, Endpoints>
    typealias EpisodesRoot = EpisodesRootFeature
    typealias Settings = SettingsFeature
  }

  @MainActor
  public struct OpaqueState {
    let viewModel: ProdViewModel
    public static func initial(
      apiURL: URL,
    ) -> Self {
      let viewModel = initialProdViewModel(
        apiURL: apiURL,
        dependencies: .prod()
      )
      return .init(viewModel: viewModel)
    }
  }

  @MainActor
  public static func rootView(opaqueState: OpaqueState) -> some View {
    return FeatureView(viewModel: opaqueState.viewModel)
  }
}
