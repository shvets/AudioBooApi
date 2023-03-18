import XCTest

@testable import AudioBooApi

class AudioBooServiceTests: XCTestCase {
  var subject = AudioBooApiService()

  func testGetLetters() async throws {
    let result = try await subject.getLetters()

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetAuthorsByLetters() async throws {
    let letters = try await subject.getLetters()

    XCTAssert(letters.count > 0)

    let id = letters[0]["id"]!

    let result = try await subject.getAuthorsByLetter(id)

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetPerformersLetters() async throws {
    let letters = try await subject.getPerformersLetters()

    XCTAssert(letters.count > 0)
  }

  func testGetPerformers() async throws {
    let performers = try await subject.getPerformers()

    XCTAssert(performers.count > 0)
  }

  func testGetAllBooks() async throws {
    let result = try await subject.getAllBooks()

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetBooks() async throws {
//    let letters = try subject.getLetters()
//
//    let letterId = letters[0]["id"]!
//
//    let authors = try subject.getAuthorsByLetter(letterId)
//
//    let url = AudioBooApiService.SiteUrl + "/" + (authors[0].value)[0].id

    let url = AudioBooApiService.SiteUrl + "/" + "/xfsearch/avtora/Пратчетт Терри"
    let result = try await subject.getBooks(url, page: 2)

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetPlaylistUrls() async throws {
    let letters = try await subject.getLetters()

    if let letterId = letters[0]["id"] {
      let authors = try await subject.getAuthorsByLetter(letterId)

      let url = AudioBooApiService.SiteUrl + "/" + (authors[4].value)[0].id

      let books = try await self.subject.getBooks(url)

      if let bookId = books[0]["id"] {
        let result = try await self.subject.getPlaylistUrls(bookId)

        print(try result.prettify())

        XCTAssert(result.count > 0)
      }
    }
  }

  func testGetAudioTracks() async throws {
    let url = "http://audioboo.ru/voina/26329-sushinskiy-bogdan-chernye-komissary.html"

    let playlistUrls = try await subject.getPlaylistUrls(url)

    let list = try await subject.getAudioTracks(playlistUrls[0])

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)

    //let file = list.filter { $0.sources != nil && $0.sources!.filter { $0.type == "mp3"} }

    //print(file)
  }

  func testGetAudioTracksNew() async throws {
    let url = "https://audioboo.org/klassika/54429-o-genri-poslednij-list.html"

    let list = try await subject.getAudioTracksNew(url)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testSearch() async throws {
    let query = "пратчетт"

    let result = try await subject.search(query)

    print(try result.prettify())
  }
}
