import Foundation
import XCTest
import SimpleHttpClient

@testable import AudioBooApi

class RedirectTests: XCTestCase {
//  class DelegateToHandle302: NSObject, URLSessionTaskDelegate {
//    var lastLocation: String? = nil
//
//    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
//                    newRequest request: URLRequest) async -> URLRequest? {
//      lastLocation = response.allHeaderFields["Location"] as? String
//
//      //print("lastLocation: \(lastLocation)")
//
//      return nil
//    }
//  }

  func testRedirect() throws {
    let delegate = DelegateToHandle302()

    let path = "/engine/go.php"

    var queryItems: Set<URLQueryItem> = []

    queryItems.insert(URLQueryItem(name: "url", value: "aHR0cDovL2FyY2hpdmUub3JnL2Rvd25sb2FkLzFfMjAyMzA5MzBfMjAyMzA5MzBfMTgwNS8xLm1wMw=="))

    var headers: Set<HttpHeader> = []

    headers.insert(HttpHeader(field: "Referer", value: "https://audioboo.org/proza/71729-holder-njensi-vne-dvenadcati-shagov-ili-leto-s-anonimnymi-alkogolikami.html"))

    var SiteUrl = "https://audioboo.org"

    var apiClient = ApiClient(URL(string: SiteUrl)!)

    let result = try apiClient.request(path, queryItems: queryItems, headers: headers, delegate: delegate)

    //print(result)

    print(result.response.allHeaderFields["Location"])

//      let result = try subject.getLetters()
//
//      print(try result.prettify())
//
//      XCTAssert(result.count > 0)
  }
}
