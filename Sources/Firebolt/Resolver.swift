
import Foundation

open class Resolver {
  public enum Scope {
    case factory
    case single
  }
  
  public let resolverId: String
  
  private var boxes: [String: BoxProtocol] = [:]
  private var cachedDependencies: [String: Any] = [:]
  
  func getBox(_ boxId: String) -> BoxProtocol? {
    globalQueue.sync { boxes[boxId] }
  }
  
  @discardableResult
  func setBox(_ boxId: String, box: BoxProtocol) -> BoxProtocol {
    globalQueue.sync { boxes[boxId] =  box }
    return box
  }
  
  func getCachedDependencies(_ dependencyId: String) -> Any? {
    globalQueue.sync { cachedDependencies[dependencyId] }
  }
  
  func setCachedDependencies<T: Any>(_ dependencyId: String, dependency: T) {
    globalQueue.sync { cachedDependencies[dependencyId] = dependency }
  }

  public init(_ resolverId: String) {
    self.resolverId = resolverId
    registerResolver(self.resolverId, resolver: self)
    logger(.info, "\(self.resolverId) - registered")
  }
  
  deinit {
    logger(.info, "\(resolverId) - deinit")
  }

  @discardableResult
  public func drop() -> Self {
    globalQueue.sync {
      boxes.removeAll()
      cachedDependencies.removeAll()
      logger(.info, "\(resolverId) - dependencies dropped")
    }
    return self
  }
  
  @discardableResult
  public func dropCompletely() -> Self {
    drop()
    deregisterResolver(self.resolverId)
    return self
  }

  public func combine(with resolver: Resolver, newResolverId: String) -> Resolver {
    let newResolver = Resolver(newResolverId)
    newResolver.boxes = resolver.boxes.merging(boxes, uniquingKeysWith: { $1 })
    return newResolver
  }
  
  func resolve<T, A, B, C, D>(
    scope: Resolver.Scope?,
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
      let resolver = self

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
      switch scope ?? box.scope() {
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
}

internal enum LogLevel: String {
  case info = "INFO"
  case error = "ERROR"
}

internal func logger(_ logLevel: LogLevel, _ value: Any) {
  print("[Resolver] \(logLevel.rawValue) - \(value)")
}
