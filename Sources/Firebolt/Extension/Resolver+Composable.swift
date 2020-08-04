//
//  Resolver+Composable.swift
//  Firebolt
//
//  Created by MacBook Pro on 8/4/20.
//

import Foundation

public extension ResolverProtocol {
  /// Merges this Resolver's dependencies with another Resolver's dependencies,
  /// If duplicate dependencies exist, the other resolver will take precedence.
  func mergeDependencies(
    with otherResolver: ResolverProtocol
  ) {
    otherResolver.coreInstance.boxes.merge(
      otherResolver.coreInstance.boxes,
      uniquingKeysWith: { $1 }
    )
  }
}
