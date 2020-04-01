
import XCTest
@testable import Viper

private let globalResolver = Resolver()

final class SwiftResolverTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
    globalResolver.drop()
  }

  func test_injection_factory() {
    let a = ClassA()
    globalResolver.register { a }
    let classA: ClassA = get()
    XCTAssertEqual(a.id, classA.id)
  }
  
  func test_injection_protocol_fail() {
    globalResolver.register { ClassA() }
    let classA: ClassAProtocol? = get()
    XCTAssertNil(classA)
  }
  
  func test_injection_protocol_fail2() {
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    XCTAssertNil(classA)
  }
  
  func test_injection_protocol() {
    globalResolver.register { ClassA() }
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    XCTAssertNotNil(classA)
  }
  
  func test_injection_protocol_register() {
    globalResolver.register(expect: ClassAProtocol.self) { ClassA() }
    let classA: ClassAProtocol? = get()
    let classA_2: ClassA? = get()
    XCTAssertNotNil(classA)
    XCTAssertNil(classA_2)
  }
  
  func test_injection_protocol_impl() {
    let name = "Hello"
    globalResolver
      .register { ClassA() }
      .register { ClassB(classA: get()) }
      .register { ClassC(classA: get(expect: ClassA.self), classB: get()) }
      .register(expect: ClassD.self) { ClassDImpl(name: name, classC: get()) }
    let classD: ClassD = get()
    XCTAssertNotNil(classD)
    XCTAssertEqual(classD.name, name)
  }
  
  func test_injection_protocol_multiple() {
    globalResolver.register { ClassA() }
    
    let classA: ClassAProtocol = get(expect: ClassA.self)
    let classA_2: ClassAProtocolB = get(expect: ClassA.self)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
  }

  func test_injection_singleton() {
    let a = ClassA()
    globalResolver.register(.single) { a }
    let classA: ClassA = get()
    XCTAssertEqual(a.id, classA.id)
  }
  
  func test_injection_1arg_default() {
    globalResolver.register(.single, arg1: String.self) { ClassA(name: $0) }
    let classA: ClassA? = get()
    XCTAssertNil(classA)
  }

  func test_injection_wrongdeps_fail() {
    globalResolver.register { ClassA() }
    let classB: ClassB? = get()
    XCTAssertNil(classB)
  }
  
  func test_injection_1arg_optional_default() {
    globalResolver.register(.single, arg1: Optional<String>.self) { ClassA(name: $0) }
    let classA: ClassA? = get()
    XCTAssertNil(classA)
  }
  
  func test_injection_1arg() {
    globalResolver.register(.single, arg1: String.self) { ClassA(name: $0) }
    let newName = "Hi"
    let classA: ClassA? = get(arg1: newName)
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, newName)
  }
  
  func test_injection_1arg_optional() {
    globalResolver.register(.single, arg1: Optional<String>.self) { ClassA(name: $0) }
    let classA: ClassA? = get(arg1: Optional<String>.none)
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, noName)
  }
  
  func test_injection_2arg_optional() {
    globalResolver.register(arg1: Optional<String>.self, arg2: Optional<Int>.self) {
      ClassA(name: $0, age: $1)
    }
    let arg1: String? = nil
    let arg2: Int? = nil
    let classA: ClassA? = get(
      arg1: arg1,
      arg2: arg2
    )
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, noName)
  }
  
  func test_injection_2arg_partial_optional() {
    globalResolver.register(arg1: Optional<String>.self, arg2: Optional<Int>.self) {
      ClassA(name: $0, age: $1)
    }
    let arg1: String = "New Name"
    let arg2: Int? = nil
    let classA: ClassA? = get(
      arg1: arg1,
      arg2: arg2
    )
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, arg1)
  }


  func test_2injection_singleton() {
    globalResolver.register(.single) { ClassA() }
    let classA: ClassA = get()
    let classA_2: ClassA = get()
    
    XCTAssertEqual(classA.id, classA_2.id)
  }

  func test_2injection_factory() {
    globalResolver.register { ClassA() }
    let classA: ClassA = get()
    let classA_2: ClassA = get()
    
    XCTAssertNotEqual(classA.id, classA_2.id)
  }

  func test_1deps_factory() {
    globalResolver.register { ClassA() }
        .register { ClassB(classA: get()) }
    let classA: ClassA = get()
    let classB: ClassB = get()
    
    XCTAssertNotEqual(classB.classA.id, classA.id)
  }
  
  func test_1deps_singleton( ){
    globalResolver.register(.single) { ClassA() }
        .register { ClassB(classA: get()) }
    let classA: ClassA = get()
    let classB: ClassB = get()

    XCTAssertEqual(classA.id, classB.classA.id)
  }
  
  func test_nested_singleton() {
    globalResolver
      .register(.single) { ClassA() }
      .register { ClassB(classA: get()) }
      .register { ClassC(classA: get(expect: ClassA.self), classB: get()) }
    let classA: ClassA = get()
    let classB: ClassB = get()
    let classC: ClassC = get()
    
    XCTAssertEqual(classC.classA.name, classA.name)
    XCTAssertEqual(classC.classB.classA.id, classA.id)
    XCTAssertNotEqual(classC.classB.id, classB.id)
  }

  func test_resolver_init() {
    let resolverId = "TEST_RESOLVER"
    let newResolver = Resolver(resolverId)
    let read = GlobalResolver.resolvers[resolverId]
    XCTAssertNotNil(read)
    XCTAssertEqual(read?.resolverId, resolverId)
    newResolver.dropCompletely()
    let read2 = GlobalResolver.resolvers[resolverId]
    XCTAssertNil(read2)
  }
  
  func test_two_resolvers() {
    let resolverId = "TEST_RESOLVER"
    let resolverId2 = "TEST_RESOLVER_2"
    _ = Resolver(resolverId)
    _ = Resolver(resolverId2)
    
    let read = GlobalResolver.resolvers[resolverId]
    let read2 = GlobalResolver.resolvers[resolverId2]
    XCTAssertNotNil(read)
    XCTAssertNotNil(read2)
    XCTAssertEqual(read?.resolverId, resolverId)
    XCTAssertEqual(read2?.resolverId, resolverId2)
  }
  
  func test_two_resolvers_same_deps() {
    let resolverId = "TEST_RESOLVER"
    let resolverId2 = "TEST_RESOLVER_2"
    let newResolver1 = Resolver(resolverId)
    let _ = Resolver(resolverId2)

    newResolver1.register { ClassA() }

    let classA: ClassA? = get(resolverId)
    let classA2: ClassA? = get(resolverId2)
    let classA3: ClassA? = get()
    
    XCTAssertNotNil(classA)
    XCTAssertNil(classA2)
    XCTAssertNil(classA3)
  }
  
  func test_two_resolvers_same_deps_one_global() {
    let resolverId = "TEST_RESOLVER"
    _ = Resolver(resolverId)

    globalResolver.register { ClassA() }

    let classA: ClassA? = get(resolverId)
    let classA2: ClassA? = get()
    
    XCTAssertNil(classA)
    XCTAssertNotNil(classA2)
  }
  
  func test_resolver_get_by_instance() {
    let resolverId = "TEST_RESOLVER"
    let resolver = Resolver(resolverId)
    
    resolver.register { ClassA() }

    let classA: ClassA? = get(resolverId)
    let classA2: ClassA? = resolver.get()
    
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA2)
  }
}
