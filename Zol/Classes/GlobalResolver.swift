
import Foundation

internal let globalResolverId: String = "GLOBAL_RESOLVER"

final class GlobalResolver {
  static private(set) var shared = Resolver(globalResolverId)
  static var resolvers: [String: Resolver] = [:]
  
  static func getResolver<T, A, B, C, D>(
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
      guard let resolver = GlobalResolver.resolvers[resolverId] else {
        throw SwiftResolverError.resolverDoesNotExist(
          resolverId: resolverId
        )
      }
      
      // Get Box
      let _box = resolver.box(boxKey)
      guard let box = _box else {
        throw SwiftResolverError.classNotRegistered(
          resolverId: resolverId, expectedObject: String(describing: T.self),
          expectedArgs: [A.self, B.self, C.self, D.self].map { String(describing: $0) },
          actualObject: _box?.stringValue ?? "nil",
          actualArgs: _box?.stringArgs ?? []
        )
      }
      
      // Get Value
      let value: T? = try box.value(arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4)
      
      // Resolve by Scope
      switch box.scope() {
      case .factory:
        return value
      case .single:
        if let value = resolver.cachedDependencies[boxKey] as? T {
          return value
        } else if resolver.cachedDependencies[boxKey] == nil, let value = value {
          resolver.cachedDependencies[boxKey] = value
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
}

