import Foundation

@main struct MutationJournalTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() throws {
    if CommandLine.arguments.count == 4, CommandLine.arguments[1] == "--crash-append" {
      let journal = try RemoteMutationJournal(url: URL(fileURLWithPath: CommandLine.arguments[2]), namespace: "account-drive")
      guard let payload = Data(base64Encoded: CommandLine.arguments[3]) else { throw POSIXError(.EINVAL) }
      try journal.append(JSONDecoder().decode(RemoteMutation.self, from: payload))
      _exit(71)
    }
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("garden-journal-\(UUID())")
    defer { try? FileManager.default.removeItem(at: directory) }
    let url = directory.appendingPathComponent("mutations.sqlite")
    let first = try RemoteMutation(operation: .rename, path: "/Before", destination: "/After")
    let second = try RemoteMutation(operation: .rmdir, path: "/After")
    do {
      let journal = try RemoteMutationJournal(url: url, namespace: "account-drive")
      try journal.append(first)
      try journal.append(second)
    }
    let recovered = try RemoteMutationJournal(url: url, namespace: "account-drive")
    try require(try recovered.first() == first, "Restart must retain the original operation ID and arguments")
    do { try recovered.acknowledge(second.operationId); throw NSError(domain: "RemoteTests", code: 2) }
    catch let error as POSIXError { try require(error.code == .EINVAL, "Out-of-order acknowledgement must fail") }
    try recovered.acknowledge(first.operationId)
    try require(try recovered.first() == second, "Recovery must preserve operation order")
    try recovered.acknowledge(second.operationId)
    try require(try recovered.first() == nil, "Completed intents must leave the journal")
    for index in 0..<RemoteMutationJournal.capacity {
      try recovered.append(RemoteMutation(operation: .createFolder, path: "/Folder \(index)"))
    }
    let retained = try recovered.first()
    do {
      try recovered.append(RemoteMutation(operation: .unlink, path: "/Overflow"))
      throw NSError(domain: "RemoteTests", code: 3)
    } catch let error as POSIXError { try require(error.code == .ENOSPC, "Full journal must reject new intents") }
    try require(try recovered.first() == retained, "Overflow must never evict an unresolved operation")
    do {
      _ = try RemoteMutationJournal(url: url, namespace: "other-account")
      throw NSError(domain: "RemoteTests", code: 4)
    } catch let error as POSIXError { try require(error.code == .EACCES, "Another account must not replay this journal") }
    var drained = 0
    while let pending = try recovered.first() {
      try recovered.acknowledge(pending.operationId)
      drained += 1
    }
    try require(drained == RemoteMutationJournal.capacity, "All intents must survive overflow and reopen")
    let child = Process()
    child.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
    child.arguments = ["--crash-append", url.path, try JSONEncoder().encode(first).base64EncodedString()]
    try child.run()
    child.waitUntilExit()
    try require(child.terminationStatus == 71, "Crash fixture must exit without closing SQLite")
    let afterCrash = try RemoteMutationJournal(url: url, namespace: "account-drive")
    try require(try afterCrash.first() == first, "An abruptly terminated helper must preserve its accepted intent")
    try afterCrash.acknowledge(first.operationId)
    for (name, code) in [("notFound", POSIXErrorCode.ENOENT), ("notEmpty", .ENOTEMPTY), ("accessDenied", .EACCES)] {
      let failure = try GardenFilesystemFailure(["code": name, "message": name])
      try require(failure.code == code, "Backend semantic errors must map to macOS errno")
    }
    print("Mutation journal: restart, ordered acknowledgement, capacity, retained intents, account isolation, and errno mapping passed")
  }
}
