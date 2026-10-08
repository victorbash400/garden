import Foundation
import Security

func nativeAuthenticationConfigured() -> Bool {
  let profile = Bundle.main.bundleURL.appendingPathComponent("Contents/embedded.provisionprofile")
  guard FileManager.default.fileExists(atPath: profile.path) else {
    return false
  }
  var code: SecCode?
  guard SecCodeCopySelf([], &code) == errSecSuccess, let code else { return false }
  var staticCode: SecStaticCode?
  guard SecCodeCopyStaticCode(code, [], &staticCode) == errSecSuccess, let staticCode else { return false }
  var information: CFDictionary?
  guard SecCodeCopySigningInformation(staticCode, SecCSFlags(rawValue: kSecCSSigningInformation), &information) == errSecSuccess,
        let values = information as? [String: Any],
        let entitlements = values[kSecCodeInfoEntitlementsDict as String] as? [String: Any],
        let domains = entitlements["com.apple.developer.associated-domains"] as? [String] else { return false }
  return domains.contains("webcredentials:garden.serverpod.space")
}
