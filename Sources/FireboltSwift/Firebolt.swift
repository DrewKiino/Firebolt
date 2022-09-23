//
//  Firebolt.swift
//  Firebolt
//
//  Created by Andrew Aquino on 6/22/20.
//

import Foundation

public class Firebolt {
  public class Config {
    public static let shared = Firebolt.Config()
    
    internal var isLoggingEnabled: Bool = true
    
    public func enableLogging(_ isLoggingEnabled: Bool) {
      self.isLoggingEnabled = isLoggingEnabled
    }
  }
}

