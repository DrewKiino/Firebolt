//
//  Stinger.swift
//
//  Created by Andrew Aquino on 3/21/20.
//  Copyright © 2020 Andrew Aquino. All rights reserved.
//

import Foundation

public typealias BoxClosureNoArg<T> = () throws -> T
public typealias BoxClosure1Arg<T, A> = (A) throws -> T
public typealias BoxClosure2Arg<T, A, B> = (A, B) throws -> T
public typealias BoxClosure3Arg<T, A, B, C> = (A, B, C) throws -> T
public typealias BoxClosure4Arg<T, A, B, C, D> = (A, B, C, D) throws -> T
public typealias BoxClosure5Arg<T, A, B, C, D, E> = (A, B, C, D, E) throws -> T
public typealias BoxClosure6Arg<T, A, B, C, D, E, F> = (A, B, C, D, E, F) throws -> T
public typealias BoxClosure7Arg<T, A, B, C, D, E, F, G> = (A, B, C, D, E, F, G) throws -> T
public typealias BoxClosure8Arg<T, A, B, C, D, E, F, G, H> = (A, B, C, D, E, F, G, H) throws -> T
public typealias BoxClosure9Arg<T, A, B, C, D, E, F, G, H, I> = (A, B, C, D, E, F, G, H, I) throws -> T
public typealias BoxClosure10Arg<T, A, B, C, D, E, F, G, H, I, J> = (A, B, C, D, E, F, G, H, I, J) throws -> T

private class GlobalResolver {
  internal static let shared = GlobalResolver()
  internal var resolvers: [String: SwiftResolver] = [:]
  internal var boxKeyToResolverIdMap: [String: String] = [:]
  internal func resolver(for resolverId: String) -> InstanceResolver? {
    resolvers[resolverId]
  }
  internal func resolver(forBoxKey boxKey: String) -> InstanceResolver? {
    guard
      let resolverId = boxKeyToResolverIdMap[boxKey],
      let resolver = resolver(for: resolverId)
      else { return nil }
    return resolver
  }
  internal func box<T>(for boxKey: String) -> T? {
    guard let box = resolver(forBoxKey: boxKey)?.boxes[boxKey] as? T else { return nil }
    return box
  }
}

public final class InstanceResolver {
  public enum Scope {
    case factory
    case single
  }
  
  internal let resolverId: String
  
  internal var boxes: [String: Any] = [:]
  internal var cachedDependencies: [String: Any] = [:]

  public init() {
    self.resolverId = UUID().uuidString
    GlobalResolverContext.shared.resolvers[resolverId] = self
  }
  
  deinit {
    GlobalResolverContext.shared.resolvers[resolverId] = nil
  }
  
  @discardableResult
  public func drop() -> Self {
    print("[SwiftResolver] dropped dependencies")
    boxes.removeAll()
    cachedDependencies.removeAll()
    return self
  }
}

internal protocol BoxProtocol {
  var valueType: String { get }
  var argsType: [String] { get }
  var scope: SwiftResolver.Scope { get }
}

public protocol SharedInstanceProtocol {
  var instanceIds: [String] { get }
}

public struct SharedInstance<A, B>: SharedInstanceProtocol {
  public var instanceIds: [String] { [] }
  public init(_ a: A.Type, _ b: B.Type) {
    
  }
}

public struct EmptySharedInstance: SharedInstanceProtocol {
  public let instanceIds: [String] = []
}

internal class Box<T, A, B, C, D>: BoxProtocol {
  internal enum Closure {
    case noargs(BoxClosureNoArg<T>)
    case arg1(BoxClosure1Arg<T, A>)
    case args2(BoxClosure2Arg<T, A, B>)
    case args3(BoxClosure3Arg<T, A, B, C>)
    case args4(BoxClosure4Arg<T, A, B, C, D>)
  }
  
  internal let scope: SwiftResolver.Scope
  internal let closure: Closure
  
  internal let valueType = String(describing: T.self)
  internal let argsType = [A.self, B.self, C.self].map { String(describing: $0) }

  public init(
    scope: SwiftResolver.Scope,
    closure: Closure,
    sharedInstance: SharedInstanceProtocol = EmptySharedInstance()
  ) {
    self.scope = scope
    self.closure = closure
  }
}

private func getBoxKey(_ any: Any) -> String {
  return String(describing: type(of: any))
}

internal enum SwiftResolverError: Error {
  case invalidKey(key: String, className: String)
  case classNotRegistered(
    expectedObject: String,
    expectedArgs: [String],
    actualObject: String,
    actualArgs: [String]
  )
  case invalidArgs(args: String, className: String)
  case invalidUnboxing
  
  var localizedDescription: String {
    switch self {
    case let .invalidKey(key, className):
      return "[SwiftResolver] invalid key \(key) for \(className)"
    case let .classNotRegistered(expectedObject, expectedArgs, actualObject, actualArgs):
      let exArgs = expectedArgs.filter { $0 != "()" }
      let acArgs = actualArgs.filter { $0 != "()" }
      return "[SwiftResolver] resolution failed - expected \(expectedObject)"
        + (exArgs.isEmpty ? "" : " with args \(exArgs)")
        + " but found \(actualObject)"
        + (acArgs.isEmpty ? "" : " with \(acArgs)")
    case let .invalidArgs(args, className):
      return "[SwiftResolver] invalid args \(args) for \(className)"
    case .invalidUnboxing:
      return "[SwiftResolver] invalid unboxing!"
    }
  }
}

public func get<T>(
  expect: T.Type = T.self
) -> T {
  get(expect: expect, arg1: (), arg2: ())
}

public func get<T, A>(
  expect: T.Type = T.self,
  arg1: A
) -> T! {
  get(expect: expect, arg1: arg1, arg2: ())
}

public func get<T, A, B>(
  expect: T.Type = T.self,
  arg1: A,
  arg2: B
) -> T! {
  get(expect: expect, arg1: arg1, arg2: (), arg3: ())
}

public func get<T, A, B, C>(
  expect: T.Type = T.self,
  arg1: A,
  arg2: B,
  arg3: C
) -> T! {
  get(expect: expect, arg1: arg1, arg2: (), arg3: (), arg4: ())
}

public func get<T, A, B, C, D>(
  expect: T.Type = T.self,
  arg1: A,
  arg2: B,
  arg3: C,
  arg4: D
) -> T! {
  let boxKey = getBoxKey(expect).clean()
  do {
    guard let resolver = GlobalResolverContext.shared.resolver(forBoxKey: boxKey) else {
      throw SwiftResolverError.classNotRegistered(
        expectedObject: String(describing: T.self),
        expectedArgs: [A.self, B.self].map { String(describing: $0) },
        actualObject: "nil",
        actualArgs: []
      )
    }
    let untypedBox = (resolver.boxes[boxKey] as? BoxProtocol)
    guard let box = untypedBox as? Box<T, A, B, C, D> else {
      throw SwiftResolverError.classNotRegistered(
        expectedObject: String(describing: T.self),
        expectedArgs: [A.self, B.self].map { String(describing: $0) },
        actualObject: untypedBox?.valueType ?? "nil",
        actualArgs: untypedBox?.argsType ?? []
      )
    }
    let valueUnwrapper: () throws -> T? = {
      switch box.closure {
      case let .noargs(closure): return try closure()
      case let .arg1(closure): return try closure(arg1)
      case let .args2(closure): return try closure(arg1, arg2)
      case let .args3(closure): return try closure(arg1, arg2, arg3)
      case let .args4(closure): return try closure(arg1, arg2, arg3, arg4)
      }
    }
    switch box.scope {
    case .factory:
      return try valueUnwrapper()
    case .single:
      if let value = resolver.cachedDependencies[boxKey] as? T {
        return value
      } else if resolver.cachedDependencies[boxKey] == nil, let value = try valueUnwrapper() {
        resolver.cachedDependencies[boxKey] = value
        return value
      }
      throw SwiftResolverError.classNotRegistered(
        expectedObject: String(describing: T.self),
        expectedArgs: [A.self, B.self].map { String(describing: $0) },
        actualObject: untypedBox?.valueType ?? "Nil",
        actualArgs: untypedBox?.argsType ?? []
      )
    }
  } catch let error {
    if let error = error as? SwiftResolverError {
      print(error.localizedDescription)
    } else {
      print(error.localizedDescription)
    }
    return nil
  }
}

/// Type Erasure for Optional<.*>, .Type, and .Protocol
private extension String {
  func clean() -> String {
    return matches(#"(?<=<)(.*)(?=>)"#).first
      ?? replacingOccurrences(of: ".Type", with: "")
        .replacingOccurrences(of: ".Protocol", with: "")
  }
}


extension SwiftResolver {
  @discardableResult
  public func register<T>(
    _ scope: Scope = .factory,
    expect object: T.Type = T.self,
    closure: @escaping BoxClosureNoArg<T>
  ) throws -> Self {
    let boxKey = getBoxKey(object.self).clean()
    GlobalResolverContext.shared.boxKeyToResolverIdMap[boxKey] = resolverId
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
    GlobalResolverContext.shared.boxKeyToResolverIdMap[boxKey] = resolverId
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
    GlobalResolverContext.shared.boxKeyToResolverIdMap[boxKey] = resolverId
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
    GlobalResolverContext.shared.boxKeyToResolverIdMap[boxKey] = resolverId
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
    GlobalResolverContext.shared.boxKeyToResolverIdMap[boxKey] = resolverId
    boxes[boxKey] = Box<T, A, B, C, D>(
      scope: scope,
      closure: .args4(closure)
    )
    print("[SwiftResolver] registered \(boxKey) with expected argument \(arg1)")
    return self
  }
}
