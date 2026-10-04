import Foundation
import Network

actor RemoteSubscription {
  private let api: GardenAPI
  private let revision: @Sendable () async throws -> Int
  private let receive: @Sendable (GardenChange) async throws -> Void
  private let path = NWPathMonitor()
  private var connection: RemoteChanges?
  private var connecting: Task<RemoteChanges, Error>?
  private var reader: Task<Void, Never>?
  private var stopped = false
  private(set) var issue: String?

  init(api: GardenAPI, revision: @escaping @Sendable () async throws -> Int,
    receive: @escaping @Sendable (GardenChange) async throws -> Void) {
    self.api = api
    self.revision = revision
    self.receive = receive
  }

  func start() async throws {
    path.pathUpdateHandler = { [weak self] current in
      if current.status == .satisfied { Task { await self?.networkAvailable() } }
    }
    path.start(queue: DispatchQueue(label: "garden.remote.network"))
    try await connect(retryConnectionFailure: true)
  }

  func reconnect() async throws {
    guard !stopped else { throw CancellationError() }
    connection?.close()
    reader?.cancel()
    try await connect(retryConnectionFailure: true)
  }

  private func connect(retryConnectionFailure: Bool) async throws {
    if let connecting { _ = try await connecting.value; return }
    let api = self.api
    let revision = self.revision
    let receive = self.receive
    let flight = Task {
      let cursor = try await revision()
      do { return try await RemoteChanges.connect(api: api, revision: cursor, receive: receive) }
      catch GardenAPIError.unauthorized {
        try await api.refreshStreamCredential()
        return try await RemoteChanges.connect(api: api, revision: cursor, receive: receive)
      }
    }
    connecting = flight
    defer { connecting = nil }
    do {
      let stream = try await flight.value
      guard !stopped else { stream.close(); throw CancellationError() }
      connection = stream
      issue = nil
      connecting = nil
      reader = Task {
        do { try await stream.run(receive: receive) }
        catch {
          if !Task.isCancelled { await self.failed(error, stream: stream, retry: retryConnectionFailure) }
        }
      }
    } catch { issue = error.localizedDescription; throw error }
  }

  private func failed(_ error: Error, stream: RemoteChanges, retry: Bool) async {
    guard !stopped, connection === stream else { return }
    issue = error.localizedDescription
    RemoteLog.error(error)
    // Retry once after a broken connection; further retries require a network or user event.
    if retry, error is URLError {
      do { try await connect(retryConnectionFailure: false) }
      catch { RemoteLog.error(error) }
    }
  }

  private func networkAvailable() async {
    guard issue != nil, !stopped else { return }
    do { try await connect(retryConnectionFailure: true) }
    catch { RemoteLog.error(error) }
  }

  func stop() {
    stopped = true
    path.cancel()
    connecting?.cancel()
    reader?.cancel()
    connection?.close()
  }
}
