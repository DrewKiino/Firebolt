//
//  Logger.swift
//  Firebolt
//
//  Created by Andrew Aquino on 6/21/20.
//

import Foundation

internal enum LogLevel: String {
  case info = "INFO"
  case error = "ERROR"
}

internal func logger(_ logLevel: LogLevel, _ value: Any) {
  guard Firebolt.Config.shared.isLoggingEnabled else { return }
  print("[Firebolt] \(logLevel.rawValue) - \(value)")
}
