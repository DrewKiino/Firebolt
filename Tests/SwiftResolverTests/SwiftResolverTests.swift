
import XCTest
@testable import SwiftResolver

private let globalResolver = SwiftResolver()

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
    do { try globalResolver.register { a } } catch {}
    let classA: ClassA = get()
    XCTAssertEqual(a.id, classA.id)
  }
  
  func test_injection_protocol_fail() {
    do { try globalResolver.register { ClassA() } } catch {}
    let classA: ClassAProtocol? = get()
    XCTAssertNil(classA)
  }
  
  func test_injection_protocol_fail2() {
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    XCTAssertNil(classA)
  }
  
  func test_injection_protocol() {
    do { try globalResolver.register { ClassA() } } catch {}
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    XCTAssertNotNil(classA)
  }

  func test_injection_singleton() {
    let a = ClassA()
    do { try globalResolver.register(.single) { a } } catch {}
    let classA: ClassA = get()
    XCTAssertEqual(a.id, classA.id)
  }
  
  func test_injection_1arg_default() {
    do { try globalResolver.register(.single, arg1: String.self) { ClassA(name: $0) } } catch {}
    let classA: ClassA? = get()
    XCTAssertNil(classA)
  }

  func test_injection_wrongdeps_fail() {
    do { try globalResolver.register { ClassA() } } catch {}
    let classB: ClassB? = get()
    XCTAssertNil(classB)
  }
  
  func test_injection_1arg_optional_default() {
    do { try globalResolver.register(.single, arg1: Optional<String>.self) { ClassA(name: $0) } } catch {}
    let classA: ClassA? = get()
    XCTAssertNil(classA)
  }
  
  func test_injection_1arg() {
    do { try globalResolver.register(.single, arg1: String.self) { ClassA(name: $0) } } catch {}
    let newName = "Hi"
    let classA: ClassA? = get(arg1: newName)
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, newName)
  }
  
  func test_injection_1arg_optional() {
    do { try globalResolver.register(.single, arg1: Optional<String>.self) { ClassA(name: $0) } } catch {}
    let classA: ClassA? = get(arg1: Optional<String>.none)
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, noName)
  }
  
  func test_injection_2arg_optional() {
    do {
      try globalResolver.register(arg1: Optional<String>.self, arg2: Optional<Int>.self) {
        ClassA(name: $0, age: $1)
      }
    } catch {}
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
    do {
      try globalResolver.register(arg1: Optional<String>.self, arg2: Optional<Int>.self) {
        ClassA(name: $0, age: $1)
      }
    } catch {}
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
    do {
      try globalResolver.register(.single) { ClassA() }
    } catch {}
    let classA: ClassA = get()
    let classA_2: ClassA = get()
    
    XCTAssertEqual(classA.id, classA_2.id)
  }

  func test_2injection_factory() {
    do {
      try globalResolver.register { ClassA() }
    } catch {}
    let classA: ClassA = get()
    let classA_2: ClassA = get()
    
    XCTAssertNotEqual(classA.id, classA_2.id)
  }

  func test_1deps_factory() {
    do {
      try globalResolver.register { ClassA() }
        .register { ClassB(classA: get()) }
    } catch {}
    let classA: ClassA = get()
    let classB: ClassB = get()
    
    XCTAssertNotEqual(classB.classA.id, classA.id)
  }
  
  func test_1deps_singleton( ){
    do {
      try globalResolver.register(.single) { ClassA() }
        .register { ClassB(classA: get()) }
    } catch {}
    let classA: ClassA = get()
    let classB: ClassB = get()

    XCTAssertEqual(classA.id, classB.classA.id)
  }
  
  func test_nested_singleton() {
    do {
      try globalResolver
        .register(.single) { ClassA() }
        .register { ClassB(classA: get()) }
        .register { ClassC(classA: get(), classB: get()) }
    } catch {}
    let classA: ClassA = get()
    let classB: ClassB = get()
    let classC: ClassC = get()
    
    XCTAssertEqual(classC.classA.id, classA.id)
    XCTAssertEqual(classC.classB.classA.id, classA.id)
    XCTAssertNotEqual(classC.classB.id, classB.id)
  }
  
  func test_nested_factory_arg() {
    do {
      try globalResolver
        .register(.single) { ClassA() }
        .register { ClassB(classA: get()) }
        .register { ClassC(classA: get(), classB: get()) }
    } catch {}
  }
  
  func test_resolver_init() {
    let resolverId = "TEST_RESOLVER"
    let newResolver = SwiftResolver(resolverId)
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
    _ = SwiftResolver(resolverId)
    _ = SwiftResolver(resolverId2)
    
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
    let newResolver1 = SwiftResolver(resolverId)
    let _ = SwiftResolver(resolverId2)

    do {
      try newResolver1.register { ClassA() }
    } catch {}
    
    let classA: ClassA? = get(resolverId: resolverId)
    let classA2: ClassA? = get(resolverId: resolverId2)
    let classA3: ClassA? = get()
    
    XCTAssertNotNil(classA)
    XCTAssertNil(classA2)
    XCTAssertNil(classA3)
  }
  
  func test_two_resolvers_same_deps_one_global() {
    let resolverId = "TEST_RESOLVER"
    _ = SwiftResolver(resolverId)

    do {
      try globalResolver.register { ClassA() }
    } catch {}
    
    let classA: ClassA? = get(resolverId: resolverId)
    let classA2: ClassA? = get()
    
    XCTAssertNil(classA)
    XCTAssertNotNil(classA2)
  }
}
