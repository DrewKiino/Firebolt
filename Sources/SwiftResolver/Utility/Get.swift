//
//  Stinger.swift
//
//  Created by Andrew Aquino on 3/21/20.
//  Copyright © 2020 Andrew Aquino. All rights reserved.
//

import Foundation

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
    guard let resolver = GlobalResolver.shared.resolver(forBoxKey: boxKey) else {
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