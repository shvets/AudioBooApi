import XCTest

@testable import AudioBooApi

class AudioBooServiceTests: XCTestCase {
  var subject = AudioBooApiService()

  func testGetLetters() throws {
    let result = try subject.getLetters()

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetAuthorsByLetters() throws {
    let letters = try subject.getLetters()

    XCTAssert(letters.count > 0)

    let id = letters[0]["id"]!

    let result = try subject.getAuthorsByLetter(id)

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetPerformersLetters() throws {
    let letters = try subject.getPerformersLetters()

    XCTAssert(letters.count > 0)
  }

  func testGetPerformers() throws {
    let performers = try subject.getPerformers()

    XCTAssert(performers.count > 0)
  }

  func testGetAllBooks() throws {
    let result = try subject.getAllBooks()

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetBooks() throws {
    let letters = try subject.getLetters()

    let letterId = letters[0]["id"]!

    let authors = try subject.getAuthorsByLetter(letterId)

    let url = AudioBooApiService.SiteUrl + "/" + (authors[0].value)[0].id

    let result = try self.subject.getBooks(url)

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetPlaylistUrls() throws {
    let letters = try subject.getLetters()

    if let letterId = letters[0]["id"] {
      let authors = try subject.getAuthorsByLetter(letterId)

      let url = AudioBooApiService.SiteUrl + "/" + (authors[4].value)[0].id

      let books = try self.subject.getBooks(url)

      if let bookId = books[0]["id"] {
        let result = try self.subject.getPlaylistUrls(bookId)

        print(try result.prettify())

        XCTAssert(result.count > 0)
      }
    }
  }

  func testGetAudioTracks() throws {
    let url = "http://audioboo.ru/voina/26329-sushinskiy-bogdan-chernye-komissary.html"

    let playlistUrls = try subject.getPlaylistUrls(url)

    let list = try subject.getAudioTracks(playlistUrls[0])

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)

    //let file = list.filter { $0.sources != nil && $0.sources!.filter { $0.type == "mp3"} }

    //print(file)
  }

  func testGetAudioTracksNew() throws {
    let url = "https://audioboo.org/klassika/54429-o-genri-poslednij-list.html"

    let list = try subject.getAudioTracksNew(url)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testSearch() throws {
    let query = "????????????????"

    let result = try subject.search(query)

    print(try result.prettify())
  }
}
