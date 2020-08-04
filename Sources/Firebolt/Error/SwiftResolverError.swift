import Foundation

enum SwiftResolverError: Error {
  case classNotRegistered(
    resolverId: String,
    expectedObject: String,
    expectedArgs: [String],
    actualObject: String,
    actualArgs: [String]
  )
  case resolverDoesNotExist(
    resolverId: String
  )

  var localizedDescription: String {
    switch self {
    case let .classNotRegistered(resolverId,  expectedObject, expectedArgs, actualObject, actualArgs):
      let exArgs = expectedArgs
        .filter { $0 != "()" || $0 != "Optional<()>" }
      let acArgs = actualArgs
        .filter { $0 != "()" || $0 != "Optional<()>" }
      return "\(resolverId) - resolution failed - expected \(expectedObject)"
        + (exArgs.isEmpty ? "" : " with args \(exArgs)")
        + " but found \(actualObject)"
        + (acArgs.isEmpty ? "" : " with args \(acArgs)")
    case  let .resolverDoesNotExist(resolverId):
      return "\(resolverId) - does not exist"
    }
  }
}
