
import Foundation

let noName = "no_name"
let noAge = 0

protocol ClassAProtocol {
  var name: String { get }
}

class BaseClass { let id: String = UUID().uuidString }

class ClassA: BaseClass, ClassAProtocol {
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
  let classA: ClassA
  let classB: ClassB
  init(classA: ClassA, classB: ClassB) {
    self.classA = classA
    self.classB = classB
  }
}
