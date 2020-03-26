import Foundation

enum SwiftResolverError: Error {
  case invalidKey(key: String, className: String)
  case classNotRegistered(
    expectedObject: String,
    expectedArgs: [String],
    actualObject: String,
    actualArgs: [String]
  )
  case invalidArgs(args: String, className: String)
  case invalidUnboxing
  
  var localizedDescription: String {
    switch self {
    case let .invalidKey(key, className):
      return "[SwiftResolver] invalid key \(key) for \(className)"
    case let .classNotRegistered(expectedObject, expectedArgs, actualObject, actualArgs):
      let exArgs = expectedArgs.filter { $0 != "()" }
      let acArgs = actualArgs.filter { $0 != "()" }
      return "[SwiftResolver] resolution failed - expected \(expectedObject)"
        + (exArgs.isEmpty ? "" : " with args \(exArgs)")
        + " but found \(actualObject)"
        + (acArgs.isEmpty ? "" : " with \(acArgs)")
    case let .invalidArgs(args, className):
      return "[SwiftResolver] invalid args \(args) for \(className)"
    case .invalidUnboxing:
      return "[SwiftResolver] invalid unboxing!"
    }
  }
}