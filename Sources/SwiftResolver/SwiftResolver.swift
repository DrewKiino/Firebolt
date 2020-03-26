
import Foundation

public final class SwiftResolver {
  public enum Scope {
    case factory
    case single
  }
  
  let resolverId: String
  
  var boxes: [String: Any] = [:]
  var cachedDependencies: [String: Any] = [:]

  public init(_ resolverId: String? = nil) {
    self.resolverId = resolverId ?? globalResolverId
    logger(.info, "\(self.resolverId) - resolver init")
    GlobalResolver.resolvers[self.resolverId] = self
  }
  
  deinit {
    logger(.info, "\(resolverId) - deinit")
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
}


extension SwiftResolver {
  static func getResolver<T, A, B, C, D>(
    expect: T.Type,
    resolverId: String,
    arg1: A,
    arg2: B,
    arg3: C,
    arg4: D
  ) -> T! {
    let boxKey = getBoxKey(expect).clean()
    do {
      guard let resolver = GlobalResolver.resolvers[resolverId] else {
        throw SwiftResolverError.classNotRegistered(
          expectedObject: String(describing: T.self),
          expectedArgs: [A.self, B.self].map { String(describing: $0) },
          actualObject: "nil",
          actualArgs: []
        )
      }
      let untypedBox = (resolver.boxes[boxKey] as? BoxProtocol)
      guard let box = untypedBox else {
        throw SwiftResolverError.classNotRegistered(
          expectedObject: String(describing: T.self),
          expectedArgs: [A.self, B.self, C.self, D.self].map { String(describing: $0) },
          actualObject: untypedBox?.valueType ?? "nil",
          actualArgs: untypedBox?.stringArgs ?? []
        )
      }
      let value: T? = try box.value(arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4)
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
        throw SwiftResolverError.classNotRegistered(
          expectedObject: String(describing: T.self),
          expectedArgs: [A.self, B.self].map { String(describing: $0) },
          actualObject: untypedBox?.valueType ?? "Nil",
          actualArgs: untypedBox?.stringArgs ?? []
        )
      }
    } catch let error {
      if let error = error as? SwiftResolverError {
        logger(.error, error.localizedDescription)
      } else {
        logger(.error, error.localizedDescription)
      }
      return nil
    }
  }
}

internal enum LogLevel: String {
  case info = "INFO"
  case error = "ERROR"
}

internal func logger(_ logLevel: LogLevel, _ value: Any) {
  print("[SwiftResolver] \(logLevel.rawValue) - \(value)")
}
