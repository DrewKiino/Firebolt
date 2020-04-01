
import Foundation

/// Type Erasure for Optional<.*>, .Type, and .Protocol
extension String {
  private func matches(_ regex: String) -> [String] {
    guard let regex = try? NSRegularExpression(
      pattern: regex,
      options: .caseInsensitive
    ) else { return [] }
    return regex.matches(
      in: self,
      options: [],
      range: NSMakeRange(0, self.count)
    ).map {
      String(self[Range($0.range, in: self)!])
    }
  }

  func clean() -> String {
    return matches(#"(?<=<)(.*)(?=>)"#).first
      ?? replacingOccurrences(of: ".Type", with: "")
        .replacingOccurrences(of: ".Protocol", with: "")
  }
}