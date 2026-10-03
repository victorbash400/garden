import Foundation

final class GardenCacheWatch {
  private let source: DispatchSourceFileSystemObject

  init(url: URL, changed: @escaping @Sendable () -> Void) throws {
    let descriptor = open(url.path, O_EVTONLY)
    guard descriptor >= 0 else {
      throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
    }
    source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor,
      eventMask: [.write], queue: .global(qos: .utility))
    source.setEventHandler(handler: changed)
    source.setCancelHandler { close(descriptor) }
    source.resume()
  }

  deinit { source.cancel() }
}
