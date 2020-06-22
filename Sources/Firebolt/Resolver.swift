
import Foundation

open class Resolver {
  public enum Scope {
    case factory
    case single
  }
  
  internal class CoreInstance {
    let resolverId: String
    
    var boxes: [String: BoxProtocol] = [:]
    var cachedDependencies: [String: Any] = [:]
    
    init(resolverId: String) {
      self.resolverId = resolverId
    }
    
    func getBox(_ boxId: String) -> BoxProtocol? {
      globalQueue.sync { boxes[boxId] }
    }
    
    func removeBox(_ boxId: String) {
      globalQueue.sync { boxes[boxId] = nil }
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

  internal let coreInstance: Resolver.CoreInstance
  public var resolverId: String { coreInstance.resolverId }

  public init(_ resolverId: String = globalResolverId) {
    if let coreInstance = getResolver(resolverId) {
      self.coreInstance = coreInstance
    } else {
      self.coreInstance = CoreInstance(resolverId: resolverId)
      registerResolver(self.resolverId, resolver: self.coreInstance)
    }
  }
  
  deinit {
    logger(.info, "\(resolverId) - deinit")
  }

  @discardableResult
  public func unregisterAllDependencies() -> Self {
    globalQueue.sync {
      coreInstance.boxes.removeAll()
      coreInstance.cachedDependencies.removeAll()
      logger(.info, "\(resolverId) - dependencies dropped")
    }
    return self
  }

  public func printAllDependencies() {
    globalQueue.sync {
      logger(.info,  "\(resolverId) - registered dependencies - \(coreInstance.boxes.map { $0.key }.joined(separator: ", "))")
    }
  }
}
