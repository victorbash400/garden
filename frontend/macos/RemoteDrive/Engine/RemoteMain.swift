import Foundation

@main struct RemoteMain {
  static func main() async {
    do {
      let arguments = CommandLine.arguments
      guard arguments.count == 7, let limit = Int64(arguments[6]), limit >= 0,
        arguments[2].hasPrefix("/Volumes/"), !arguments[3].contains(",") else {
        throw POSIXError(.EINVAL)
      }
      try GardenCachePolicy.validate(limit)
      let mountURL = URL(fileURLWithPath: arguments[2]).standardizedFileURL
      guard mountURL.deletingLastPathComponent().path == "/Volumes",
        !arguments[3].isEmpty, arguments[3].utf8.count < 500 else { throw POSIXError(.EINVAL) }
      try RemotePlatform.requireModule()
      let engine = try RemoteEngine(domainID: arguments[1], state: URL(fileURLWithPath: arguments[4]),
        cache: URL(fileURLWithPath: arguments[5]), limit: limit)
      try await engine.prepare()
      let mount = try await RemoteMount.start(engine: engine, path: arguments[2], name: arguments[3])
      try await mount.run()
      await engine.stop()
    } catch { RemoteLog.error(error); exit(1) }
  }
}
