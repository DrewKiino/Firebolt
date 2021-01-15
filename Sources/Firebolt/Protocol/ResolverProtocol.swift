//
//  ResolverProtocol.swift
//  Firebolt
//
//  Created by Andrew Aquino on 7/13/20.
//

import Foundation

public protocol ResolverProtocol {
  var coreInstance: Resolver.CoreInstance { get }
  
  var resolverId: String { get }
  
  func unregister<T>(_ object: T.Type)
  
  @discardableResult
  func unregister(_ dependencies: [Any]) -> Self
  @discardableResult
  func unregisterAllDependencies(except dependencies: [Any]) -> Self
  
  @discardableResult
  func dropCached(_ dependencies: [Any]) -> Self
  @discardableResult
  func dropAllCachedDependencies(except dependencies: [Any]) -> Self
  
  func printAllDependencies()
  
  @discardableResult
  func register<T>(
    _ scope: Resolver.Scope,
    expect object: T.Type,
    closure: @escaping BoxClosureNoArg<T>
  ) -> Self
  
  @discardableResult
  func register<T, A>(
    _ scope: Resolver.Scope,
    expect object: T.Type,
    arg1: A.Type,
    closure: @escaping BoxClosure1Arg<T, A>
  ) -> Self
  
  @discardableResult
  func register<T, A, B>(
    scope: Resolver.Scope,
    expect object: T.Type,
    arg1: A.Type,
    arg2: B.Type,
    closure: @escaping BoxClosure2Arg<T, A, B>
  ) -> Self
  
  @discardableResult
  func register<T, A, B, C>(
    scope: Resolver.Scope,
    expect object: T.Type,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    closure: @escaping BoxClosure3Arg<T, A, B, C>
  ) -> Self
  
  @discardableResult
  func register<T, A, B, C, D>(
    scope: Resolver.Scope,
    expect object: T.Type,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    arg4: D.Type,
    closure: @escaping BoxClosure4Arg<T, A, B, C, D>
  ) -> Self
  
  @discardableResult
  func register<T, R: ResolverProtocol>(
    _ scope: Resolver.Scope,
    expect object: T.Type,
    closure: @escaping BoxClosureNoArgR<T, R>
  ) -> Self

  @discardableResult
  func register<T, R: ResolverProtocol, A>(
    _ scope: Resolver.Scope,
    expect object: T.Type,
    arg1: A.Type,
    closure: @escaping BoxClosure1ArgR<T, R, A>
  ) -> Self

  @discardableResult
  func register<T, R: ResolverProtocol, A, B>(
    scope: Resolver.Scope,
    expect object: T.Type,
    arg1: A.Type,
    arg2: B.Type,
    closure: @escaping BoxClosure2ArgR<T, R, A, B>
  ) -> Self

  @discardableResult
  func register<T, R: ResolverProtocol, A, B, C>(
    scope: Resolver.Scope,
    expect object: T.Type,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    closure: @escaping BoxClosure3ArgR<T, R, A, B, C>
  ) -> Self

  @discardableResult
  func register<T, R: ResolverProtocol, A, B, C, D>(
    scope: Resolver.Scope,
    expect object: T.Type,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    arg4: D.Type,
    closure: @escaping BoxClosure4ArgR<T, R, A, B, C, D>
  ) -> Self

  func get<T>(
    _ scope: Resolver.Scope?,
    expect: T.Type
  ) -> T!

  func get<T, A>(
    _ scope: Resolver.Scope?,
    expect: T.Type,
    arg1: A
  ) -> T!

  func get<T, A, B>(
    _ scope: Resolver.Scope?,
    expect: T.Type,
    arg1: A,
    arg2: B
  ) -> T!

  func get<T, A, B, C>(
    _ scope: Resolver.Scope?,
    expect: T.Type,
    arg1: A,
    arg2: B,
    arg3: C
  ) -> T!

  func get<T, A, B, C, D>(
    _ scope: Resolver.Scope?,
    expect: T.Type,
    arg1: A,
    arg2: B,
    arg3: C,
    arg4: D
  ) -> T!
}

public extension ResolverProtocol {
  @discardableResult
  func register<T>(
    _ scope: Resolver.Scope = .single,
    closure: @escaping BoxClosureNoArg<T>
  ) -> Self {
    register(scope, expect: T.self, closure: closure)
  }
  
  @discardableResult
  func register<T, R>(
    _ scope: Resolver.Scope = .single,
    closure: @escaping BoxClosureNoArgR<T, R>
  ) -> Self {
    register(scope, expect: T.self, closure: closure)
  }
  
  func get<T>(
    _ scope: Resolver.Scope? = nil,
    expect: T.Type = T.self
  ) -> T! {
    coreInstance.resolve(
      scope: scope,
      expect: expect,
      resolverId: resolverId,
      arg1: null, arg2: null, arg3: null, arg4: null
    )
  }
}
