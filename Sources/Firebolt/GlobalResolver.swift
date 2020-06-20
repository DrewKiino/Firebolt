
import Foundation

public let globalResolverId: String = UUID().uuidString
internal let globalQueue = DispatchQueue.global(qos: .default)
internal let globalResolver = Resolver(globalResolverId)
internal var resolvers: [String: Resolver] = [:]

func getResolver(_ resolverId: String) -> Resolver? {
  globalQueue.sync { resolvers[resolverId] }
}

func deregisterResolver(_ resolverId: String) {
  globalQueue.sync { resolvers[resolverId] = nil }
}

func registerResolver(_ resolverId: String, resolver: Resolver) {
  globalQueue.sync { resolvers[resolverId] = resolver }
}

