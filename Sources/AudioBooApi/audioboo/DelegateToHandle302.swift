import Foundation

final class DelegateToHandle302: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
  var lastLocation: String? = nil

  func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                  newRequest request: URLRequest) async -> URLRequest? {
    lastLocation = response.allHeaderFields["Location"] as? String

    return nil
  }
}
