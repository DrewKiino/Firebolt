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
    otherResolver.coreInstance.dependencyIdToResolutionId.merge(
      otherResolver.coreInstance.dependencyIdToResolutionId,
      uniquingKeysWith: { $1 }
    )
    otherResolver.coreInstance.resolutionIdToBox.merge(
      otherResolver.coreInstance.resolutionIdToBox,
      uniquingKeysWith: { $1 }
    )
  }
}
