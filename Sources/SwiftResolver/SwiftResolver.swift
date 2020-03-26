
import Foundation

public final class SwiftResolver {
  public enum Scope {
    case factory
    case single
  }
  
  let resolverId: String
  
  var boxes: [String: Any] = [:]
  var cachedDependencies: [String: Any] = [:]

  public init() {
    self.resolverId = UUID().uuidString
    GlobalResolver.shared.resolvers[resolverId] = self
  }
  
  deinit {
    GlobalResolver.shared.resolvers[resolverId] = nil
  }
  
  @discardableResult
  public func drop() -> Self {
    print("[SwiftResolver] dropped dependencies")
    boxes.removeAll()
    cachedDependencies.removeAll()
    return self
  }
}
