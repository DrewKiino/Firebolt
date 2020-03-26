
import Foundation

internal class GlobalResolver {
  internal static let shared = GlobalResolver()
  internal var resolvers: [String: SwiftResolver] = [:]
  internal var boxKeyToResolverIdMap: [String: String] = [:]
  internal func resolver(for resolverId: String) -> SwiftResolver? {
    resolvers[resolverId]
  }
  internal func resolver(forBoxKey boxKey: String) -> SwiftResolver? {
    guard
      let resolverId = boxKeyToResolverIdMap[boxKey],
      let resolver = resolver(for: resolverId)
      else { return nil }
    return resolver
  }
  internal func box<T>(for boxKey: String) -> T? {
    guard let box = resolver(forBoxKey: boxKey)?.boxes[boxKey] as? T else { return nil }
    return box
  }
}