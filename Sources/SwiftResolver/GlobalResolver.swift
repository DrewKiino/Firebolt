
import Foundation

class GlobalResolver {
  static let shared = GlobalResolver()
  var resolvers: [String: SwiftResolver] = [:]
  var boxKeyToResolverIdMap: [String: String] = [:]
  func resolver(for resolverId: String) -> SwiftResolver? {
    resolvers[resolverId]
  }
  func resolver(forBoxKey boxKey: String) -> SwiftResolver? {
    guard
      let resolverId = boxKeyToResolverIdMap[boxKey],
      let resolver = resolver(for: resolverId)
      else { return nil }
    return resolver
  }
  func box<T>(for boxKey: String) -> T? {
    guard let box = resolver(forBoxKey: boxKey)?.boxes[boxKey] as? T else { return nil }
    return box
  }
}