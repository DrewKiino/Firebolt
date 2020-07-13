//
//  InstanceProtocol.swift
//  Firebolt
//
//  Created by Andrew Aquino on 7/12/20.
//

import Foundation

protocol InstanceProtocol {
  func getInstance<T>() -> T?
}

struct Instance<V>: InstanceProtocol {
  let instance: V
  init(_ instance: V) {
    self.instance = instance
  }
  func getInstance<T>() -> T? {
    return instance as? T
  }
}


