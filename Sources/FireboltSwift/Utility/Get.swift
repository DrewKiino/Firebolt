//
//  Stinger.swift
//
//  Created by Andrew Aquino on 3/21/20.
//  Copyright © 2020 Andrew Aquino. All rights reserved.
//

import Foundation

public func get<T>(
  resolverId: String = globalResolverId,
  expect: T.Type = T.self
) -> T! {
  getResolver(resolverId)?.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: null, arg2: null, arg3: null, arg4: null
  )
}

public func get<T, A>(
  resolverId: String = globalResolverId,
  expect: T.Type = T.self,
  _ arg1: A
) -> T! {
  getResolver(resolverId)?.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: arg1, arg2: null, arg3: null, arg4: null
  )
}

public func get<T, A, B>(
  resolverId: String = globalResolverId,
  expect: T.Type = T.self,
  _ arg1: A,
  _ arg2: B
) -> T! {
  getResolver(resolverId)?.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: arg1, arg2: arg2, arg3: null, arg4: null
  )
}

public func get<T, A, B, C>(
  resolverId: String = globalResolverId,
  expect: T.Type = T.self,
  _ arg1: A,
  _ arg2: B,
  _ arg3: C
) -> T! {
  getResolver(resolverId)?.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: arg1, arg2: arg2, arg3: arg3, arg4: null
  )
}

public func get<T, A, B, C, D>(
  resolverId: String = globalResolverId,
  expect: T.Type = T.self,
  _ arg1: A,
  _ arg2: B,
  _ arg3: C,
  _ arg4: D
) -> T! {
  getResolver(resolverId)?.resolve(
    scope: nil,
    expect: expect,
    resolverId: globalResolverId,
    arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4
  )
}
