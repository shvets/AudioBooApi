import SimpleHttpClient

import UIKit


let SiteUrl = "https://audioboo.org"

let apiClient = ApiClient(URL(string: SiteUrl)!)

class DelegateToHandle302: NSObject, URLSessionTaskDelegate {
    var lastLocation: String? = nil
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest) async -> URLRequest? {
      lastLocation = response.allHeaderFields["Location"] as? String
        
      //print("lastLocation: \(lastLocation)")

      return Optional(request)
    }
}

let delegate = DelegateToHandle302()

func getHeaders(_ referer: String="") -> Set<HttpHeader> {
    var headers: Set<HttpHeader> = []

    headers.insert(HttpHeader(field: "Referer", value: "https://audioboo.org/detsklit/71728-roj-kristina-v-strane-solnca.html"))

  return headers
}

let headers = getHeaders()

let path = "/engine/go.php"

var queryItems: Set<URLQueryItem> = []

queryItems.insert(URLQueryItem(name: "url", value: "aHR0cDovL2FyY2hpdmUub3JnL2Rvd25sb2FkLzFfMjAyMzA5MzBfMjAyMzA5MzBfMTgwNS8xLm1wMw=="))

Task.init {
    let response = try await apiClient.requestAsync(path, queryItems: queryItems, headers: headers)
    
    print(response.response.url)
}
