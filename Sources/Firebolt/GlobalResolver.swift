
import Foundation

public let globalResolverId: String = "GLOBAL_RESOLVER"
internal let globalQueue = DispatchQueue.global(qos: .default)
internal var resolvers: [String: Resolver.CoreInstance] = [:]

func getResolver(_ resolverId: String) -> Resolver.CoreInstance? {
  globalQueue.sync { resolvers[resolverId] }
}

func unregisterResolver(_ resolverId: String) {
  globalQueue.sync { resolvers[resolverId] = nil }
}

func registerResolver(_ resolverId: String, resolver: Resolver.CoreInstance) {
  globalQueue.sync {
    guard resolvers[resolverId] == nil else {
      return logger(.error, "Resolver \(resolverId) is already registered.")
    }
    resolvers[resolverId] = resolver
    logger(.info, "\(resolverId) - registered")
  }
}
