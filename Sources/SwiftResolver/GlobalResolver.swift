
import Foundation

public let globalResolverId: String = "GLOBAL_RESOLVER"

final class GlobalResolver {
  static private(set) var shared = SwiftResolver(globalResolverId)
  static var resolvers: [String: SwiftResolver] = [:]
}
