//
//  FireboltConfig.swift
//  Firebolt
//
//  Created by Andrew Aquino on 6/22/20.
//

import Foundation

public class FireboltConfig {
  public static let shared = FireboltConfig()
  
  internal var isLoggingEnabled: Bool = true
  
  public func enableLogging(_ isLoggingEnabled: Bool) {
    self.isLoggingEnabled = isLoggingEnabled
  }
}
