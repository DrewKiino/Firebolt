
import Foundation

let noName = "no_name"
let noAge = 0

protocol ClassD {
  var name: String { get }
}

protocol ClassAProtocol {
  var name: String { get }
}

protocol ClassAProtocolB {
  var age: Int { get }
}

class BaseClass { let id: String = UUID().uuidString }

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
