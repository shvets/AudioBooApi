import Foundation
import SimpleHttpClient
import Codextended

extension AudioBooApiService {
  public typealias BookItem = [String: String]

  public struct PersonName {
    public let name: String
    public let id: String

    public init(name: String, id: String) {
      self.name = name
      self.id = id
    }
  }

  public struct BooSource: Codable {
    public let file: String
    public let type: String
    public let height: String
    public let width: String

    public init(file: String, type: String, height: String, width: String) {
      self.file = file
      self.type = type
      self.height = height
      self.width = width
    }
  }

  public struct BooTrack2: Codable {
    public let title: String
    public let file: String
  }

  public struct BooTrack: Codable {
    public let title: String
    public let orig: String
    public let image: String
    public let duration: String
    public let sources: [BooSource]

    enum CodingKeys: String, CodingKey {
      case title
      case orig
      case image
      case duration
      case sources
    }

    public var url: String {
      get {
        "\(AudioBooApiService.ArchiveUrl)\(sources[0].file)"
      }
    }

//  public var thumb: String {
//    get {
//      return "\(AudioBooAPI.SiteUrl)\(image)"
//    }
//  }

    public init(title: String, orig: String, image: String, duration: String, sources: [BooSource]) throws {
      self.title = title
      self.orig = orig
      self.image = image
      self.duration = duration
      self.sources = sources
    }


    public init(from decoder: Decoder) throws {
      title = try decoder.decode("title")
      orig = try decoder.decode("orig")

      do {
        image = (try decoder.decode("image")) ?? ""
      }
      catch {
        image = ""
      }

      do {
        duration = (try decoder.decode("duration")) ?? ""
      }
      catch {
        duration = ""
      }

      sources = (try decoder.decode("sources")) ?? []
    }
  }
}
