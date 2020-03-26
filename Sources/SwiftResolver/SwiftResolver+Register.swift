
import Foundation

extension SwiftResolver {

  @discardableResult
  public func register<T>(
    _ scope: Scope = .factory,
    expect object: T.Type = T.self,
    closure: @escaping BoxClosureNoArg<T>
  ) throws -> Self {
    let boxKey = getBoxKey(object.self).clean()
    GlobalResolver.shared.boxKeyToResolverIdMap[boxKey] = resolverId
    boxes[boxKey] = Box<T, Void, Void, Void, Void>(
      scope: scope,
      closure: .noargs(closure)
    )
    print("[SwiftResolver] registered \(boxKey)")
    return self
  }
  
  @discardableResult
  public func register<T, A>(
    _ scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    closure: @escaping BoxClosure1Arg<T, A>
  ) throws -> Self {
    let boxKey = getBoxKey(object.self).clean()
    GlobalResolver.shared.boxKeyToResolverIdMap[boxKey] = resolverId
    boxes[boxKey] = Box<T, A, Void, Void, Void>(
      scope: scope,
      closure: .arg1(closure)
    )
    print("[SwiftResolver] registered \(boxKey) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B>(
    scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    closure: @escaping BoxClosure2Arg<T, A, B>
  ) throws -> Self {
    let boxKey = getBoxKey(object.self).clean()
    GlobalResolver.shared.boxKeyToResolverIdMap[boxKey] = resolverId
    boxes[boxKey] = Box<T, A, B, Void, Void>(
      scope: scope,
      closure: .args2(closure)
    )
    print("[SwiftResolver] registered \(boxKey) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C>(
    scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    closure: @escaping BoxClosure3Arg<T, A, B, C>
  ) throws -> Self {
    let boxKey = getBoxKey(object.self).clean()
    GlobalResolver.shared.boxKeyToResolverIdMap[boxKey] = resolverId
    boxes[boxKey] = Box<T, A, B, C, Void>(
      scope: scope,
      closure: .args3(closure)
    )
    print("[SwiftResolver] registered \(boxKey) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C, D>(
    scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    arg4: D.Type,
    closure: @escaping BoxClosure4Arg<T, A, B, C, D>
  ) throws -> Self {
    let boxKey = getBoxKey(object.self).clean()
    GlobalResolver.shared.boxKeyToResolverIdMap[boxKey] = resolverId
    boxes[boxKey] = Box<T, A, B, C, D>(
      scope: scope,
      closure: .args4(closure)
    )
    print("[SwiftResolver] registered \(boxKey) with expected argument \(arg1)")
    return self
  }
}
