//
//  Stinger.swift
//
//  Created by Andrew Aquino on 3/21/20.
//  Copyright © 2020 Andrew Aquino. All rights reserved.
//

import Foundation

public func get<T>(
  expect: T.Type = T.self
) -> T! {
  globalResolver.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: null, arg2: null, arg3: null, arg4: null
  )
}

public func get<T, A>(
  expect: T.Type = T.self,
  _ arg1: A
) -> T! {
  globalResolver.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: arg1, arg2: null, arg3: null, arg4: null
  )
}

public func get<T, A, B>(
  expect: T.Type = T.self,
  _ arg1: A,
  _ arg2: B
) -> T! {
  globalResolver.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: arg1, arg2: arg2, arg3: null, arg4: null
  )
}

public func get<T, A, B, C>(
  expect: T.Type = T.self,
  _ arg1: A,
  _ arg2: B,
  _ arg3: C
) -> T! {
  globalResolver.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: arg1, arg2: arg2, arg3: arg3, arg4: null
  )
}

public func get<T, A, B, C, D>(
  expect: T.Type = T.self,
  _ arg1: A,
  _ arg2: B,
  _ arg3: C,
  _ arg4: D
) -> T! {
  globalResolver.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4
  )
}
