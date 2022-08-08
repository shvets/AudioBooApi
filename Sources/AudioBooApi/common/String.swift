import Foundation

extension String {
  public func find(_ sub: String) -> String.Index? {
    self.range(of: sub)?.lowerBound
  }

  public func trim() -> String {
    trimmingCharacters(in: .whitespaces)
  }

  public func addingPercentEncoding(withAllowedCharacters characterSet: CharacterSet, using encoding: String.Encoding) -> String {
    let stringData = data(using: encoding, allowLossyConversion: true) ?? Data()

    let percentEscaped = stringData.map {byte->String in
      if characterSet.contains(UnicodeScalar(byte)) {
        return String(UnicodeScalar(byte))
      }
      else if byte == UInt8(ascii: " ") {
        return "+"
      }
      else {
        return String(format: "%%%02X", byte)
      }
    }.joined()

    return percentEscaped
  }

  public func windowsCyrillicPercentEscapes() -> String {
    let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    let encoding = CFStringEncoding(CFStringEncodings.windowsCyrillic.rawValue)

    let windowsCyrillic = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(encoding))

    return addingPercentEncoding(withAllowedCharacters: rfc3986Unreserved,  using: windowsCyrillic)
  }

//  func replaceFirst(of pattern: String, with replacement: String) -> String {
//    if let range = self.range(of: pattern) {
//      return self.replacingCharacters(in: range, with: replacement)
//    } else {
//      return self
//    }
//  }
//
//  func replaceAll(of pattern: String, with replacement: String, options: NSRegularExpression.Options = []) -> String {
//    do {
//      let regex = try NSRegularExpression(pattern: pattern, options: [])
//      let range = NSRange(0..<utf16.count)
//      return regex.stringByReplacingMatches(in: self, options: [],
//          range: range, withTemplate: replacement)
//    } catch {
//      return self
//    }
//  }
}