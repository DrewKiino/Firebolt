
import Foundation

public final class Resolver {
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
