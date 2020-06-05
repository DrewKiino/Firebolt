
import Foundation
@testable import Firebolt

let noName = "no_name"
let noAge = 0

protocol BaseClassProtocol {}
class BaseClass: BaseClassProtocol { let id: String = UUID().uuidString }

protocol ClassD {
  var name: String { get }
}

protocol ClassAProtocol {
  var name: String { get }
}

protocol ClassAProtocolB {
  var age: Int { get }
}

class ClassA: BaseClass, ClassAProtocol, ClassAProtocolB {
  let name: String
  let age: Int
  init(name: String = noName) {
    self.name = name
    self.age = noAge
  }
  
  init(name: String? = nil, age: Int? = nil) {
    self.name = name ?? noName
    self.age = age ?? noAge
  }
}

class ClassB: BaseClass {
  let classA: ClassA
  init(classA: ClassA) {
    self.classA = classA
  }
}

class ClassC: BaseClass {
  let classA: ClassAProtocol
  let classB: ClassB
  init(classA: ClassAProtocol, classB: ClassB) {
    self.classA = classA
    self.classB = classB
  }
}

class ClassDImpl: ClassD {
  let name: String
  let classC: ClassC
  init(name: String, classC: ClassC) {
    self.name = name
    self.classC = classC
  }
}

protocol ClassEProtocol {
  var name: String { get }
}

protocol ClassEProtocolB {
  var age: Int { get }
}

protocol ClassE: ClassEProtocol, ClassEProtocolB {}

class ClassEImpl: ClassE, ClassEProtocol, ClassEProtocolB {
  let name: String
  let age: Int
  init(name: String? = nil, age: Int? = nil) {
    self.name = name ?? noName
    self.age = age ?? noAge
  }
}

class ResolverSubclass: Resolver {
  init() {
    super.init("ResolverSubclass")
  }
}

class ResolverSubclassSelfRegister: Resolver {
  static let shared = ResolverSubclassSelfRegister()
  init() {
    super.init("ResolverSubclassSelfRegister")
    register { ClassA() }
  }
}
