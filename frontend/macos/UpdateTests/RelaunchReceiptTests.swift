import Foundation
import Darwin

@main enum ReceiptTest {
  @MainActor static func main() async throws {
    if CommandLine.arguments.contains("--child") {
      usleep(500_000)
      let arguments = ["Garden", GardenSessionHandoff.argument, CommandLine.arguments.last!]
      let payload = try GardenSessionHandoff.consume(arguments: arguments)
      precondition((payload["main"] as? [String: String])?["auth"] == "test-session")
      GardenRelaunchReceipt.acknowledge(arguments: arguments, accepted: true)
      return
    }
    let name = try GardenSessionHandoff.create(["main": ["auth": "test-session"]])
    let receipt = GardenRelaunchReceipt(name: name)
    let child = Process()
    child.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
    child.arguments = ["--child", name]
    try child.run()
    try await receipt.wait()
    child.waitUntilExit()
    precondition(child.terminationStatus == 0)
    print("Delayed child session handoff acknowledged successfully")
  }
}
