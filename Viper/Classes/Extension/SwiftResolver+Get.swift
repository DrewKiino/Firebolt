//
//  Viper+Get.swift
//  Viper
//
//  Created by Andrew Aquino on 3/26/20.
//

import Foundation

extension Viper {
  public func get<T>(
    expect: T.Type = T.self
  ) -> T! {
    GlobalResolver.getResolver(
      expect: expect,
      resolverId: resolverId,
      arg1: (), arg2: (), arg3: (), arg4: ()
    )
  }

  public func get<T, A>(
    expect: T.Type = T.self,
    arg1: A
  ) -> T! {
    GlobalResolver.getResolver(
      expect: expect,
      resolverId: resolverId,
      arg1: arg1, arg2: (), arg3: (), arg4: ()
    )
  }

  public func get<T, A, B>(
    expect: T.Type = T.self,
    arg1: A,
    arg2: B
  ) -> T! {
    GlobalResolver.getResolver(
      expect: expect,
      resolverId: resolverId,
      arg1: arg1, arg2: arg2, arg3: (), arg4: ()
    )
  }

  public func get<T, A, B, C>(
    expect: T.Type = T.self,
    arg1: A,
    arg2: B,
    arg3: C
  ) -> T! {
    GlobalResolver.getResolver(
      expect: expect,
      resolverId: resolverId,
      arg1: arg1, arg2: arg2, arg3: arg3, arg4: ()
    )
  }

  public func get<T, A, B, C, D>(
    expect: T.Type = T.self,
    arg1: A,
    arg2: B,
    arg3: C,
    arg4: D
  ) -> T! {
    GlobalResolver.getResolver(
      expect: expect,
      resolverId: resolverId,
      arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4
    )
  }
}
