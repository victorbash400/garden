import Foundation
import FSKit

final class GardenStreamingFileSystem: FSUnaryFileSystem, FSUnaryFileSystemOperations {
  private func domain(_ resource: FSResource) throws -> String {
    guard let resource = resource as? FSGenericURLResource,
          resource.url.scheme == "garden", let host = resource.url.host,
          host.hasPrefix("account-"), host.contains("-drive-") else {
      throw POSIXError(.EINVAL)
    }
    _ = try FinderCredentialStore.read(host)
    return host
  }

  func probeResource(resource: FSResource, replyHandler: @escaping (FSProbeResult?, Error?) -> Void) {
    do {
      let id = try domain(resource)
      guard let uuid = UUID(uuidString: try FinderCredentialStore.read(id).accountID) else { throw POSIXError(.EINVAL) }
      guard let identifier = FSContainerIdentifier(uuid: uuid, qualifierData: Data(id.utf8)) else { throw POSIXError(.EINVAL) }
      replyHandler(.usable(name: "Garden", containerID: identifier), nil)
    } catch { replyHandler(nil, error) }
  }

  func loadResource(resource: FSResource, options: FSTaskOptions,
    replyHandler: @escaping (FSVolume?, Error?) -> Void) {
    do {
      let id = try domain(resource)
      replyHandler(try GardenStreamingVolume(domainID: id), nil)
    } catch { replyHandler(nil, error) }
  }

  func unloadResource(resource: FSResource, options: FSTaskOptions) async throws {}
}
