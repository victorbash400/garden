import Foundation

/// Window membership is separate from the helper's persistent Finder sessions.
final class WindowAccounts {
  private var accounts: [String: String] = [:]

  func set(_ account: String, window: String) {
    accounts[window] = account
  }

  func contains(_ window: String) -> Bool { accounts[window] != nil }

  func release(_ window: String) -> Bool {
    guard let account = accounts.removeValue(forKey: window) else { return false }
    return !accounts.values.contains(account)
  }
}
