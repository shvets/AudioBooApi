import Foundation
import SwiftSoup
import SimpleHttpClient

class DelegateToHandle302: NSObject, URLSessionTaskDelegate {
  var lastLocation: String? = nil

  func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                  newRequest request: URLRequest) async -> URLRequest? {
    lastLocation = response.allHeaderFields["Location"] as? String

    return request
  }
}

open class AudioBooApiService {
  public static let SiteUrl = "https://audioboo.org"
  public static let ArchiveUrl = "https://archive.org"

  let apiClient = ApiClient(URL(string: SiteUrl)!)
  let archiveClient = ApiClient(URL(string: ArchiveUrl)!)

  public init() {}

  public static func getURLPathOnly(_ url: String, baseUrl: String) -> String {
    String(url[baseUrl.index(url.startIndex, offsetBy: baseUrl.count)...])
  }

  func getPagePath(path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page/\(page)/"
    }
  }

  func getHeaders(_ referer: String="") -> Set<HttpHeader> {
    var headers: Set<HttpHeader> = []

    if !referer.isEmpty {
      headers.insert(HttpHeader(field: "Referer", value: referer))
    }

    return headers
  }

  func getRedirectLocation(path: String, url: String) throws -> String? {
    let delegate = DelegateToHandle302()

    let semaphore = DispatchSemaphore(value: 0)

    Task {
      if path.hasPrefix("/engine/go.php?url=") {
        var queryItems: Set<URLQueryItem> = []

        let range = path.index(path.startIndex, offsetBy: "/engine/go.php?url=".count)..<path.endIndex

        queryItems.insert(URLQueryItem(name: "url", value: String(path[range])))

        let _ = try await apiClient.requestAsync("/engine/go.php", queryItems: queryItems, headers: getHeaders(url), delegate: delegate)
      }

      semaphore.signal()
    }

    semaphore.wait()

    return delegate.lastLocation
  }

  public func getLetters() throws -> [[String: String]] {
    var result = [[String: String]]()

    if let document = try getDocumentSync() {
      let items = try document.select("div[class=left-col] a[class=alfavit]")

      for item in items.array() {
        let name = try item.text()

        let href = try item.attr("href")

        result.append(["id": href, "name": name.uppercased()])
      }
    }

    return result
  }

  public func getAuthorsByLetter(_ path: String) throws -> [NameClassifier.ItemsGroup] {
    var groups: [String: [NameClassifier.Item]] = [:]

    if let document = try getDocumentSync(path) {
      let items = try document.select("div[class=news-item-content] div a")

      for item in items.array() {
        let href = try item.attr("href")
        let name = try item.text().trim()

        if !name.isEmpty && !name.hasPrefix("ALIAS") && Int(name) == nil {
          let index1 = name.startIndex

          var index2: String.Index

          if name.count > 2 {
            index2 = name.index(name.startIndex, offsetBy: 3)
          }
          else {
            index2 = name.index(name.startIndex, offsetBy: name.count)
          }

          let groupName = name[index1 ..< index2].uppercased()

          if !groups.keys.contains(groupName) {
            groups[groupName] = []
          }

          var group: [NameClassifier.Item] = []

          if let subGroup = groups[groupName] {
            for item in subGroup {
              group.append(item)
            }
          }

          group.append(NameClassifier.Item(id: href, name: name))

          groups[groupName] = group
        }
      }
    }

    var newGroups: [NameClassifier.ItemsGroup] = []

    for (groupName, group) in groups.sorted(by: { $0.key < $1.key}) {
      newGroups.append(NameClassifier.ItemsGroup(key: groupName, value: group))
    }

    return NameClassifier().mergeSmallGroups(newGroups)
  }

  public func getPerformersLetters() throws -> [[String: String]] {
    var letters: [[String: String]] = []

    if let document = try getDocumentSync("tags/") {
      let items = try document.select("div[id=dle-content] div[id=dle-content] div[class=clearfix cloud-tags] h3")

      for item in items.array() {
        let name = try item.text().uppercased()

        if !name.isEmpty && Int(name) == nil {
          letters.append(["name": name, "id": name])
        }
      }
    }

    return letters
  }

  public func getPerformers() throws -> [NameClassifier.ItemsGroup] {
    var groups: [String: [NameClassifier.Item]] = [:]

    if let document = try getDocumentSync("tags/") {
      let items = try document.select("div[id=dle-content] div[id=dle-content] span[class^=clouds] a")

      for item in items.array() {
        let href = try item.attr("href")

        let name = try item.text()

        let index1 = name.startIndex
        let index2 = name.count > 2 ? name.index(name.startIndex, offsetBy: 3) :
            name.index(name.startIndex, offsetBy: 2)

        let groupName = name[index1 ..< index2].uppercased()

        if !groups.keys.contains(groupName) {
          groups[groupName] = []
        }

        var group: [NameClassifier.Item] = []

        if let subGroup = groups[groupName] {
          for item in subGroup {
            group.append(item)
          }
        }

        group.append(NameClassifier.Item(id: href, name: name))

        groups[groupName] = group
      }
    }

    var newGroups: [NameClassifier.ItemsGroup] = []

    for (groupName, group) in groups.sorted(by: { $0.key < $1.key}) {
      newGroups.append(NameClassifier.ItemsGroup(key: groupName, value: group))
    }

    return NameClassifier().mergeSmallGroups(newGroups)
  }

  public func getAllBooks(page: Int=1) async throws -> [BookItem] {
    var result = [BookItem]()

    let path = getPagePath(path: "", page: page)

    if let document = try await getDocument(path) {
      //let items = try document.select("div[id=dle-content] div[id=dle-content] article")
      let items = try document.select("div[id=dle-content] div[id=dle-content] article[class=card d-flex]")

      for item: Element in items.array() {
        var name = try item.select("a")[0].text()
        var href = try item.select("a").attr("href")

        if name.isEmpty {
          name = try item.select("div h2[class=card__title] a").text()
          href = try item.select("div h2[class=card__title] a").attr("href")
        }

        var thumb = try item.select("a[class=card__img img-fit-cover] img").attr("src")

        let index = thumb.find("https://")

        if index != thumb.startIndex {
          thumb = AudioBooApiService.SiteUrl + thumb
        }

        result.append(["type": "book", "id": href, "name": name, "thumb": thumb])
      }
    }

    return result
  }

  public func getBooks(_ url: String, page: Int=1) async throws -> [BookItem] {
    var result = [BookItem]()

    let pagePath = getPagePath(path: "", page: page)

    var newUrl = ""

    if url.starts(with: "http://") || url.starts(with: "https://") {
      newUrl = url
    }
    else {
      newUrl = AudioBooApiService.SiteUrl + "/" + url
    }

    let path = AudioBooApiService.getURLPathOnly("\(newUrl)/\(pagePath)", baseUrl: AudioBooApiService.SiteUrl)

    if let document = try await getDocument(path) {
      let items = try document.select("div[id=dle-content] div[id=dle-content] article")

      for item: Element in items.array() {
        let name = try  item.select("a img").attr("alt")
        let href = try item.select("a").attr("href")
        let thumb = try item.select("a img").attr("src")

        //let content = try item.select("div[class=biography-content]").text()

        //let elements = try item.select("div[class=biography-content] div").array()

        //let rating = try elements[0].select("div[class=rating] ul li[class=current-rating]").text()

        result.append(["type": "book", "id": href, "name": name, "thumb": AudioBooApiService.SiteUrl + thumb])
      }
    }

    return result
  }

  public func getPlaylistUrls(_ url: String) async throws -> [String] {
    var result = [String]()

    let path = AudioBooApiService.getURLPathOnly(url, baseUrl: AudioBooApiService.SiteUrl)

    if let document = try await getDocument(path) {
      let items = try document.select("object")

      if items.count > 0 {
        for item: Element in items.array() {
          result.append(try item.attr("data"))
        }
      }
//      else {
//        let script = try document.select("script")
//
//        if script.count > 0 {
//          let content = try script[0].text()
//
//          let index1 = content.find("file:")
//          let index2 = content.find("});")
//
//          if let index1 = index1, let index2 = index2 {
//            let text = content.substring(from: index1, to: index2)
//          }
//
////          for item2: Element in playerLinks.array() {
////            //result.append(try item.attr("data"))
////            print(item2)
////          }
//        }
//      }
    }

    return result
  }

  public func getAudioTracks(_ url: String) throws -> [BooTrack] {
    var result = [BooTrack]()

    let path = AudioBooApiService.getURLPathOnly(url, baseUrl: AudioBooApiService.ArchiveUrl)

    let response = try archiveClient.request(path)

    if let data = response.data, let document = try toDocument(data: data, encoding: .utf8) {

      let items = try document.select("input[class=js-play8-playlist]")

      for item in items.array() {
        let value = try item.attr("value")

        if let data = value.data(using: .utf8),
           let tracks = try archiveClient.decode(data, to: [BooTrack].self) {
          result = tracks
        }
      }
    }

    return result
  }

  public func getAudioTracksNew(_ url: String) throws -> [BooTrack2] {
    var result = [BooTrack2]()

    let path = AudioBooApiService.getURLPathOnly(url, baseUrl: AudioBooApiService.ArchiveUrl)

    if let document = try getDocumentSync(path) {
      let scripts = try document.select("script")

      for script in scripts {
        let text = try script.html()

        if !text.trim().isEmpty {
          let index1 = text.find("file:")
          let index2 = text.find("}]")

          if let index1 = index1, let index2 = index2 {
            let index3 = text.index(index1, offsetBy: 5)
            let index4 = text.index(index2, offsetBy: 1)

            let body = String(text[index3 ... index4])
            //.replacingOccurrences(of: " ", with: "")
            //.replacingOccurrences(of: "\n", with: "")a


            if let data = body.data(using: .utf8),
               let items = try apiClient.decode(data, to: [BooTrack2].self) {
              result = items
            }
          }
        }
      }
    }

    return result.map { item in
      if item.file.hasPrefix("/engine/go.php") {
        do {
          let location = try getRedirectLocation(path: item.file, url: url)

          return BooTrack2(title: item.title, file: location ?? "")
        }
        catch {
          return item
        }
      }
      else {
        return item
      }
    }
  }

  public func search(_ query: String, page: Int=1) async throws -> [[String: String]] {
    var result = [[String: String]]()

    let path = "engine/ajax/controller.php"

    let content = "query=\(query)" +
        "&user_hash=44b399630c1d719b937474f99676e6e60accf1d8"
    let body = content.data(using: .utf8, allowLossyConversion: false)

    let cookie = try getCookie()
    //print(cookie)

    var headers: Set<HttpHeader> = []
    headers.insert(HttpHeader(field: "content-type", value: "application/x-www-form-urlencoded; charset=UTF-8"))
    headers.insert(HttpHeader(field: "cookie", value: cookie!))

    var queryItems: Set<URLQueryItem> = []
    queryItems.insert(URLQueryItem(name: "mod", value: "search"))

    //for index in 1...10 {
      let response = try await apiClient.requestAsync(path, method: .post, queryItems: queryItems, headers: headers, body: body)

      if let data = response.data, let document = try toDocument(data: data) {
        print(try document.text())

        if try document.text().starts(with: "Ваша пользовательская сессия истекла") {
          let items = try document.select("a")

          for item in items.array() {
            let name = try item.text()

            let href = try item.attr("href")

            result.append(["type": "book", "id": href, "name": name])
          }
        }
        else {
          //  break
        }
      }
    //}

    return result
  }

  func getCookie() throws -> String?  {
    let headers: Set<HttpHeader> = [
      HttpHeader(field: "user-agent", value:
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36")
    ]

    var cookie: String = ""

    let _ = try apiClient.request(headers: headers)

    if let cookies = HTTPCookieStorage.shared.cookies {
      for c in cookies {
        //if c.name == "PHPSESSID" {
          cookie += "\(c.name)=\(c.value); "
        //}
      }
    }

    return cookie
  }

  public func getDocument(_ path: String = "") async throws -> Document? {
    var document: Document? = nil

    let response = try await apiClient.requestAsync(path)

    if let data = response.data {
      document = try data.toDocument()
    }

    return document
  }

  public func getDocumentSync(_ path: String = "") throws -> Document? {
    var document: Document? = nil

    let response = try apiClient.request(path)

    if let data = response.data {
      document = try data.toDocument(encoding: .utf8)
    }

    return document
  }

  func toDocument(data: Data, encoding: String.Encoding = .utf8) throws -> Document? {
    try data.toDocument(encoding: encoding)
  }
}
