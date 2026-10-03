import FileProvider
import Foundation

enum GardenProviderError {
  static func wrap(_ error: Error) -> Error {
    if error is CancellationError { return CocoaError(.userCancelled) }
    if case GardenAPIError.unauthorized = error { return NSFileProviderError(.notAuthenticated) }
    if let network = error as? URLError {
      return NSError(domain: NSFileProviderErrorDomain, code: NSFileProviderError.serverUnreachable.rawValue,
        userInfo: [NSUnderlyingErrorKey: network])
    }
    let original = error as NSError
    if original.domain == NSCocoaErrorDomain || original.domain == NSFileProviderErrorDomain { return error }
    return NSError(domain: NSCocoaErrorDomain, code: NSXPCConnectionReplyInvalid,
      userInfo: [NSUnderlyingErrorKey: original, NSLocalizedDescriptionKey: error.localizedDescription])
  }
}
