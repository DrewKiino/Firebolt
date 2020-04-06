//
//  Stinger.swift
//
//  Created by Andrew Aquino on 3/21/20.
//  Copyright © 2020 Andrew Aquino. All rights reserved.
//

import Foundation

public func get<T>(
  expect: T.Type = T.self,
  resolverId: String? = nil
) -> T! {
  Resolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: (), arg2: (), arg3: (), arg4: ()
  )
}

public func get<T, A>(
  expect: T.Type = T.self,
  resolverId: String? = nil,
  _ arg1: A
) -> T! {
  Resolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: arg1, arg2: (), arg3: (), arg4: ()
  )
}

public func get<T, A, B>(
  expect: T.Type = T.self,
  resolverId: String? = nil,
  _ arg1: A,
  _ arg2: B
) -> T! {
  Resolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: arg1, arg2: arg2, arg3: (), arg4: ()
  )
}

public func get<T, A, B, C>(
  expect: T.Type = T.self,
  resolverId: String? = nil,
  _ arg1: A,
  _ arg2: B,
  _ arg3: C
) -> T! {
  Resolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: arg1, arg2: arg2, arg3: arg3, arg4: ()
  )
}

public func get<T, A, B, C, D>(
  expect: T.Type = T.self,
  resolverId: String? = nil,
  _ arg1: A,
  _ arg2: B,
  _ arg3: C,
  _ arg4: D
) -> T! {
  Resolver.getResolver(
    expect: expect,
    resolverId: resolverId ?? globalResolverId,
    arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4
  )
}
