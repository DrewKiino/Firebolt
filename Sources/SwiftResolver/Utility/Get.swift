//
//  Stinger.swift
//
//  Created by Andrew Aquino on 3/21/20.
//  Copyright © 2020 Andrew Aquino. All rights reserved.
//

import Foundation

public func get<T>(
  expect: T.Type = T.self,
  _  resolverId: String? = nil
) -> T! {
  GlobalResolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: (), arg2: (), arg3: (), arg4: ()
  )
}

public func get<T, A>(
  expect: T.Type = T.self,
  _ resolverId: String? = nil,
  arg1: A
) -> T! {
  GlobalResolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: arg1, arg2: (), arg3: (), arg4: ()
  )
}

public func get<T, A, B>(
  expect: T.Type = T.self,
  _ resolverId: String? = nil,
  arg1: A,
  arg2: B
) -> T! {
  GlobalResolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: arg1, arg2: arg2, arg3: (), arg4: ()
  )
}

public func get<T, A, B, C>(
  expect: T.Type = T.self,
  _ resolverId: String? = nil,
  arg1: A,
  arg2: B,
  arg3: C
) -> T! {
  GlobalResolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: arg1, arg2: arg2, arg3: arg3, arg4: ()
  )
}

public func get<T, A, B, C, D>(
  expect: T.Type = T.self,
  _ resolverId: String? = nil,
  arg1: A,
  arg2: B,
  arg3: C,
  arg4: D
) -> T! {
  GlobalResolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4
  )
}
