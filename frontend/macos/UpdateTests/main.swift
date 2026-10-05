import Foundation
import Darwin

let first = try GardenSessionHandoff.create([
  "main": ["auth": "test-session-a"], "second": ["auth": "test-session-b"],
])
let payload = try GardenSessionHandoff.consume(name: first)
precondition((payload["main"] as? [String: String])?["auth"] == "test-session-a")
precondition((payload["second"] as? [String: String])?["auth"] == "test-session-b")
do {
  _ = try GardenSessionHandoff.consume(name: first)
  fatalError("The handoff must only be consumed once")
} catch {}
let unsigned = try GardenSessionHandoff.create(["main": [:]])
let empty = try GardenSessionHandoff.consume(arguments: ["Garden", GardenSessionHandoff.argument, unsigned])
precondition((empty["main"] as? [String: String])?.isEmpty == true)
let ordinary = try GardenSessionHandoff.consume(arguments: ["Garden"])
precondition(ordinary.isEmpty)
print("Session handoff tests passed")
