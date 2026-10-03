import Foundation

struct GardenObjectRequests {
  static func upload(_ request: URLRequest, data: Data) async throws {
    for attempt in 0..<3 {
      do {
        let (body, response) = try await URLSession.shared.upload(for: request, from: data)
        guard let response = response as? HTTPURLResponse else { throw GardenAPIError.invalidResponse }
        guard response.statusCode == 200 else {
          let parser = XMLParser(data: body)
          let detail = GardenObjectError()
          parser.delegate = detail
          _ = parser.parse()
          throw GardenAPIError.http(response.statusCode, detail.message.isEmpty
            ? HTTPURLResponse.localizedString(forStatusCode: response.statusCode) : detail.message)
        }
        return
      } catch {
        guard attempt < 2, retryable(error) else { throw error }
        try await Task.sleep(for: .milliseconds(250 * (attempt + 1)))
      }
    }
  }

  static func read(_ request: URLRequest) async throws -> (Data, URLResponse) {
    for attempt in 0..<3 {
      do { return try await URLSession.shared.data(for: request) }
      catch {
        guard attempt < 2, retryable(error) else { throw error }
        try await Task.sleep(for: .milliseconds(250 * (attempt + 1)))
      }
    }
    throw GardenAPIError.invalidResponse
  }

  private static func retryable(_ error: Error) -> Bool {
    if let error = error as? URLError {
      return [.networkConnectionLost, .timedOut, .cannotConnectToHost].contains(error.code)
    }
    if case GardenAPIError.http(let status, _) = error { return status >= 500 && status <= 599 }
    return false
  }
}

private final class GardenObjectError: NSObject, XMLParserDelegate {
  private var element = ""
  var message = ""
  func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String]) { element = name }
  func parser(_ parser: XMLParser, foundCharacters text: String) {
    if element == "Code" || element == "Message" { message += text }
  }
  func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName: String?) {
    if name == "Code" { message += ": " }
    element = ""
  }
}
