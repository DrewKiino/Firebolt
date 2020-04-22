
import Foundation

internal let globalResolverId: String = "GLOBAL_RESOLVER"

final class GlobalResolver {
  static private(set) var shared = Resolver(globalResolverId)
  static var resolvers: [String: Resolver] = [:]
}

