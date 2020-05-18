
import Foundation

public class Resolver {
  public enum Scope {
    case factory
    case single
  }
  
  public let resolverId: String
  
  internal var boxes: [String: BoxProtocol] = [:]
  internal var cachedDependencies: [String: Any] = [:]

  public init(_ resolverId: String? = nil) {
    self.resolverId = resolverId ?? globalResolverId
    logger(.info, "\(self.resolverId) - resolver init")
    GlobalResolver.resolvers[self.resolverId] = self
  }
  
  deinit {
    logger(.info, "\(resolverId) - deinit")
  }
  
  internal func box(_ boxKey: String) -> BoxProtocol? {
    boxes[boxKey]
  }
  
  @discardableResult
  public func drop() -> Self {
    boxes.removeAll()
    cachedDependencies.removeAll()
    logger(.info, "\(resolverId) - dependencies dropped")
    return self
  }
  
  @discardableResult
  public func dropCompletely() -> Self {
    drop()
    GlobalResolver.resolvers[self.resolverId] = nil
    return self
  }

  public func combine(with resolver: Resolver, newResolverId: String) -> Resolver {
    let newResolver = Resolver(newResolverId)
    newResolver.boxes = resolver.boxes.merging(boxes, uniquingKeysWith: { $1 })
    return newResolver
  }
}

internal enum LogLevel: String {
  case info = "INFO"
  case error = "ERROR"
}

internal func logger(_ logLevel: LogLevel, _ value: Any) {
  print("[Resolver] \(logLevel.rawValue) - \(value)")
}

internal extension Resolver {
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
      
      // Resolve by Scope
      switch box.scope() {
      case .factory:
        return try box.value(arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4)
      case .single:
        if let value = resolver.cachedDependencies[boxKey] as? T {
          return value
        } else if resolver.cachedDependencies[boxKey] == nil {
          let value: T? = try box.value(arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4)
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
