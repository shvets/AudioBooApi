import SimpleHttpClient
import Foundation


class DelegateToHandle302: NSObject, URLSessionTaskDelegate {
    var lastLocation: String? = nil
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest) async -> URLRequest? {
      lastLocation = response.allHeaderFields["Location"] as? String
        
      print("lastLocation: \(lastLocation)")

      return Optional(request)
    }
}

func execute() throws -> ApiResponse {
    let delegate = DelegateToHandle302()

    let path = "/engine/go.php"
    
    var queryItems: Set<URLQueryItem> = []

    queryItems.insert(URLQueryItem(name: "url", value: "aHR0cDovL2FyY2hpdmUub3JnL2Rvd25sb2FkLzFfMjAyMzA5MzBfMjAyMzA5MzBfMTgwNS8xLm1wMw=="))

    var headers: Set<HttpHeader> = []

    headers.insert(HttpHeader(field: "Referer", value: "https://audioboo.org/proza/71729-holder-njensi-vne-dvenadcati-shagov-ili-leto-s-anonimnymi-alkogolikami.html"))
    
    var SiteUrl = "https://audioboo.org"
    
    var apiClient = ApiClient(URL(string: SiteUrl)!)
        
    return try apiClient.request(path, queryItems: queryItems, headers: headers, delegate: delegate)
}


//Task {
let response = try execute()

print()
print(response.response.url!)
//}
