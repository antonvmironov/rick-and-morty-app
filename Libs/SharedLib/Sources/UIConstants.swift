import Foundation

public enum UIConstants {
  public static let space: CGFloat = 8
  public static let cornerRadius: CGFloat = space
  public static let borderWidth: CGFloat = 1

  public static let inPreview: Bool =
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
