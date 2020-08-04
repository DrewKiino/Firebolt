//
//  MockResolver.swift
//  Firebolt
//
//  Created by MacBook Pro on 8/4/20.
//

import Foundation

open class MockResolver: Resolver {
  public init(configureDependencies: (MockResolver) -> ()) {
    super.init()
    configureDependencies(self)
  }
}
