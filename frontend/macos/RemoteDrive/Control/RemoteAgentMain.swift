import AppKit
import Darwin
import Foundation

@main struct RemoteAgentMain {
  static func main() {
    do { try run() }
    catch {
      FileHandle.standardError.write(Data("Garden remote service: \(error.localizedDescription)\n".utf8))
      exit(1)
    }
  }

  private static func run() throws {
    let files = FileManager.default
    let root = files.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("GardenRemote")
    let cacheURL = files.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("GardenRanges")
    let manager = try RemoteManager(root: root, cache: cacheURL)
    let service = RemoteControlService(manager: manager, cache: GardenDiskCache(directory: cacheURL))
    let listener = NSXPCListener(machServiceName: GardenRemoteService.name)
    listener.delegate = service
    listener.resume()
    let wake = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didWakeNotification, object: nil, queue: nil
    ) { _ in Task { await manager.restore() } }
    signal(SIGTERM, SIG_IGN)
    signal(SIGINT, SIG_IGN)
    let sources = [SIGTERM, SIGINT].map { signal in
      let source = DispatchSource.makeSignalSource(signal: signal, queue: .main)
      source.setEventHandler {
        Task {
          do { try await manager.shutdown(); exit(0) }
          catch { RemoteLog.error(error); exit(1) }
        }
      }
      source.resume()
      return source
    }
    Task { await manager.restore() }
    withExtendedLifetime((listener, service, wake, sources)) { RunLoop.main.run() }
  }
}
