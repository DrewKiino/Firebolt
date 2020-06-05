
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

  public init(_ resolverId: String? = nil) {
    self.resolverId = resolverId ?? globalResolverId
    logger(.info, "\(self.resolverId) - resolver init")
    registerResolver(self.resolverId, resolver: self)
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
}

internal enum LogLevel: String {
  case info = "INFO"
  case error = "ERROR"
}

internal func logger(_ logLevel: LogLevel, _ value: Any) {
  print("[Resolver] \(logLevel.rawValue) - \(value)")
}
