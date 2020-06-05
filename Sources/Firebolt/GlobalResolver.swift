
import Foundation

internal let globalResolverId: String = "GLOBAL_RESOLVER"
internal let globalQueue = DispatchQueue.global(qos: .default)

final class GlobalResolver {
  static private(set) var shared = Resolver(globalResolverId)
  fileprivate static var resolvers: [String: Resolver] = [:]
}

func resolve<T, A, B, C, D>(
  expect: T.Type,
  resolverId: String,
  arg1: A,
  arg2: B,
  arg3: C,
  arg4: D
) -> T! {
  do {
    // Get Key
    let boxKey = getBoxKey(expect).clean()
    
    // Get Resolver
    guard let resolver = getResolver(resolverId) else {
      throw SwiftResolverError.resolverDoesNotExist(
        resolverId: resolverId
      )
    }
    
    // Get Box
    let _box = resolver.getBox(boxKey)
    guard let box = _box else {
      throw SwiftResolverError.classNotRegistered(
        resolverId: resolverId, expectedObject: String(describing: T.self),
        expectedArgs: [A.self, B.self, C.self, D.self].map { String(describing: $0) },
        actualObject: _box?.stringValue ?? "nil",
        actualArgs: _box?.stringArgs ?? []
      )
    }
    
    // Resolve by Scope
    switch box.scope() {
    case .factory:
      return try box.value(arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4)
    case .single:
      if let value = resolver.getCachedDependencies(boxKey) as? T {
        return value
      } else if resolver.getCachedDependencies(boxKey) == nil {
        let value: T? = try box.value(arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4)
        resolver.setCachedDependencies(boxKey, dependency: value)
        return value
      }
    }
    
  } catch let error {
    if let error = error as? SwiftResolverError {
      logger(.error, error.localizedDescription)
    } else {
      logger(.error, error.localizedDescription)
    }
  }
  return nil
}

func getResolver(_ resolverId: String) -> Resolver? {
  globalQueue.sync { GlobalResolver.resolvers[resolverId] }
}

func deregisterResolver(_ resolverId: String) {
  globalQueue.sync { GlobalResolver.resolvers[resolverId] = nil }
}

func registerResolver(_ resolverId: String, resolver: Resolver) {
  globalQueue.sync { GlobalResolver.resolvers[resolverId] = resolver }
}

