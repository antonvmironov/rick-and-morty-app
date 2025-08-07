import Foundation
import SharedLib
import SwiftUI

extension SkeletonFeature {
  @MainActor protocol FeatureViewModel: AnyObject, Observable {
    var pi: Double { get }
    var number: Int { get }
    func increment(by value: Int)
    func decrement()
  }

  struct FeatureView<ViewModel: FeatureViewModel>: View {
    static var incrementValue: Int { 3 }

    @Bindable var viewModel: ViewModel

    var body: some View {
      List {
        LabeledContent("pi", value: viewModel.pi, format: .number)
        LabeledContent("number", value: viewModel.number, format: .number)
        HStack(alignment: .center, spacing: UIConstants.space) {
          Button("increment") {
            viewModel.increment(by: Self.incrementValue)
          }
          .buttonStyle(.borderedProminent)
          Button("decrement") {
            viewModel.decrement()
          }
          .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
      }
    }
  }

  @Observable final class MockViewModel: FeatureViewModel {
    init() {}

    // MARK: - FeatureViewModel
    var pi: Double { 3 }
    var number: Int { 42 }
    func increment(by value: Int) { /* no-op */  }
    func decrement() { /* no-op */  }
  }

  @MainActor static func previewViewModel() -> MockViewModel {
    MockViewModel()
  }
}

#Preview {
  SkeletonFeature.FeatureView(viewModel: SkeletonFeature.previewViewModel())
}
