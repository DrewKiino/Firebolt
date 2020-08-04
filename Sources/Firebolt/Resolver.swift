
import Foundation

open class Resolver: ResolverProtocol {
  public enum Scope {
    case factory
    case single
  }
  
  public class CoreInstance {
    let resolverId: String
    
    var boxes: [String: BoxProtocol] = [:]
    var cachedInstances: [String: InstanceProtocol] = [:]
    
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
    
    func getCachedInstance(_ dependencyId: String) -> InstanceProtocol? {
      globalQueue.sync { cachedInstances[dependencyId] }
    }
    
    func setCachedInstance<T: Any>(_ dependencyId: String, dependency: T) {
      globalQueue.sync { cachedInstances[dependencyId] = Instance(dependency) }
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
        let dependencyId = getDependencyId(expect).clean()
        
        // Get Resolver
        let resolver = self
        
        // Get Box
        let _box = resolver.getBox(dependencyId)
        guard let box = _box else {
          throw SwiftResolverError.classNotRegistered(
            resolverId: resolverId, expectedObject: String(describing: T.self),
            expectedArgs: [A.self, B.self, C.self, D.self]
              .map { String(describing: $0) }
              .filter { $0 != "Optional<()>" }
            ,
            actualObject: _box?.stringValue ?? "nil",
            actualArgs: _box?.stringArgs ?? []
          )
        }
        
        // Resolve by Scope
        switch scope ?? box.scope() {
        case .factory:
          return try box.value(arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4)
        case .single:
          if let instance = resolver.getCachedInstance(dependencyId) {
            let value: T? = instance.getInstance()
            return value
          } else if resolver.getCachedInstance(dependencyId) == nil {
            let value: T? = try box.value(arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4)
            resolver.setCachedInstance(dependencyId, dependency: value)
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

  public let coreInstance: Resolver.CoreInstance
  public var resolverId: String { coreInstance.resolverId }
  
  public init(_ resolverId: String = UUID().uuidString) {
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

  public func unregister<T>(_ object: T.Type) {
    let dependencyId = getDependencyId(object.self).clean()
    coreInstance.removeBox(dependencyId)
  }
  
  @discardableResult
  public func unregister(_ dependencies: [Any]) -> Self {
    globalQueue.sync {
      if dependencies.isEmpty { return }
      let dependencyIds = Set(dependencies.map { getDependencyId($0) })
      coreInstance.boxes = coreInstance.boxes
        .filter { key, _ in !dependencyIds.contains(key) }
      logger(.info, "\(resolverId) - unregistered dependencies \(dependencies)")
    }
    return self
  }

  @discardableResult
  public func unregisterAllDependencies(except dependencies: [Any] = []) -> Self {
    globalQueue.sync {
      let dependencyIds = Set(dependencies.map { getDependencyId($0) })
      if dependencyIds.isEmpty {
        coreInstance.boxes.removeAll()
      } else {
        coreInstance.boxes = coreInstance.boxes
          .filter { key, _ in dependencyIds.contains(key) }
      }
      let exceptString = dependencies.isEmpty
        ? ""
        : " except \(dependencyIds)"
      logger(.info, "\(resolverId) - unregistered all dependencies\(exceptString)")
    }
    return self
  }
  
  @discardableResult
  public func dropCached(_ dependencies: [Any]) -> Self {
    globalQueue.sync {
      let dependencyIds = Set(dependencies.map { getDependencyId($0) })
      coreInstance.cachedInstances = coreInstance.cachedInstances
        .filter { key, _ in !dependencyIds.contains(key) }
      logger(.info, "\(resolverId) - dropped cached dependencies \(dependencies)")
    }
    return self
  }
  
  @discardableResult
  public func dropAllCachedDependencies(except dependencies: [Any] = []) -> Self {
    globalQueue.sync {
      let dependencyIds = Set(dependencies.map { getDependencyId($0) })
      if dependencyIds.isEmpty {
        coreInstance.cachedInstances.removeAll()
      } else {
        coreInstance.cachedInstances = coreInstance.cachedInstances
          .filter { key, _ in dependencyIds.contains(key) }
      }
      let exceptString = dependencies.isEmpty
        ? ""
        : " except \(dependencyIds)"
      logger(.info, "\(resolverId) - dropped cached all dependencies\(exceptString)")
    }
    return self
  }

  public func printAllDependencies() {
    globalQueue.sync {
      logger(.info,  "\(resolverId) - registered dependencies - \(coreInstance.boxes.map { $0.key }.joined(separator: ", "))")
    }
  }
}
