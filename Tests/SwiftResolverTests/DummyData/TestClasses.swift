
import Foundation

class BaseClass { let id: String = UUID().uuidString }

class ClassA: BaseClass {}
class ClassB: BaseClass { init(classA: ClassA) {} }