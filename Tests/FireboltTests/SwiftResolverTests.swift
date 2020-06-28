
import XCTest
@testable import Firebolt

final class SwiftResolverTests: XCTestCase {
  
  private let globalResolver = Resolver()

  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
    globalResolver.unregisterAllDependencies()
    globalResolver.dropAllCachedDependencies()
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

  func test_injection_double_protocol() {
    globalResolver.register { ClassA() }
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    let classA_B: ClassAProtocolB? = get(expect: ClassA.self)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_B)
  }

  func test_injection_double_protocol_impl() {
    globalResolver.register(expect: ClassE.self) { ClassEImpl() }
    let classE: ClassEProtocol? = get(expect: ClassE.self)
    let classE_B: ClassEProtocolB? = get(expect: ClassE.self)
    XCTAssertNotNil(classE)
    XCTAssertNotNil(classE_B)
  }

  func test_injection_double_protocol_concrete() {
    globalResolver.register { ClassA() }
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    let classA_B: ClassAProtocolB? = get(expect: ClassA.self)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_B)
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
    let classA2: ClassA = get()
    XCTAssertEqual(a.id, classA.id)
    XCTAssertEqual(a.id, classA2.id)
  }
  
  func test_injection_singleton_unique() {

    let resolver = Resolver(UUID().uuidString)
      .register(.single) { ClassA() }
    
    let classA: ClassA? = resolver.get()
    let classA2: ClassA? = get()
    let classA3: ClassA? = resolver.get()
    
    XCTAssertNotNil(classA)
    XCTAssertNil(classA2)
    XCTAssertNotNil(classA3)
    XCTAssertEqual(classA?.id, classA3?.id)
  }
  
  func test_injection_singleton_subclass() {
    let resolver = ResolverSubclass()
      .register(.single) { ClassA() }
    
    let classA: ClassA? = resolver.get()
    let classA2: ClassA? = get()
    let classA3: ClassA? = resolver.get()
    
    XCTAssertNotNil(classA)
    XCTAssertNil(classA2)
    XCTAssertNotNil(classA3)
    XCTAssertEqual(classA?.id, classA3?.id)
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

  func test_injection_1arg_optional_default_singleton() {
    globalResolver.register(.single, arg1: String?.self) { ClassA(name: $0) }
    let name = "hello"
    let classA: ClassA? = get()
    let classA_2: ClassA? = get(name)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
    XCTAssertNotEqual(classA_2?.name, name)
  }

  func test_injection_1arg_optional_default() {
    globalResolver.register(arg1: String?.self) { ClassA(name: $0) }
    let name = "hello"
    let classA: ClassA? = get()
    let classA_2: ClassA? = get(name)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
    XCTAssertEqual(classA_2?.name, name)
  }

  func test_injection_1arg() {
    globalResolver.register(.single, arg1: String.self) { ClassA(name: $0) }
    let newName = "Hi"
    let classA: ClassA? = get(newName)
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, newName)
  }

  func test_injection_1arg_optional() {
    globalResolver.register(.single, arg1: String?.self) { ClassA(name: $0) }
    let classA: ClassA? = get(String?.none)
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, noName)
  }

  func test_injection_2arg_optional() {
    globalResolver.register(arg1: String?.self, arg2: Int?.self) {
      ClassA(name: $0, age: $1)
    }
    let arg1: String? = nil
    let arg2: Int? = nil
    let classA: ClassA? = get(
      arg1,
      arg2
    )
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, noName)
  }

  func test_injection_2arg_partial_optional() {
    globalResolver.register(arg1: String?.self, arg2: Int?.self) {
      ClassA(name: $0, age: $1)
    }
    let arg1: String = "New Name"
    let arg2: Int? = nil
    let classA: ClassA? = get(
      arg1,
      arg2
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

  func test_two_resolvers() {
    let resolverId = "TEST_RESOLVER"
    let resolverId2 = "TEST_RESOLVER_2"
    _ = Resolver(resolverId)
    _ = Resolver(resolverId2)

    let read = getResolver(resolverId)
    let read2 = getResolver(resolverId2)
    XCTAssertNotNil(read)
    XCTAssertNotNil(read2)
    XCTAssertEqual(read?.resolverId, resolverId)
    XCTAssertEqual(read2?.resolverId, resolverId2)
  }

  func test_two_resolvers_same_deps() {
    let resolverId = UUID().uuidString
    let resolverId2 = UUID().uuidString
    let newResolver1 = Resolver(resolverId)
    let newResolver2 = Resolver(resolverId2)

    newResolver1.register { ClassA() }

    let classA: ClassA? = newResolver1.get()
    let classA2: ClassA? = newResolver2.get()
    let classA3: ClassA? = get()

    XCTAssertNotNil(classA)
    XCTAssertNil(classA2)
    XCTAssertNil(classA3)
  }

  func test_two_resolvers_same_deps_one_global() {
    let resolverId = UUID().uuidString
    let resolver = Resolver(resolverId)

    globalResolver.register { ClassA() }

    let classA: ClassA? = resolver.get()
    let classA2: ClassA? = get()

    XCTAssertNil(classA)
    XCTAssertNotNil(classA2)
  }

  func test_resolver_get_by_instance() {
    let resolverId = UUID().uuidString
    let resolver = Resolver(resolverId)

    resolver.register { ClassA() }

    let classA: ClassA? = resolver.get()
    let classA2: ClassA? = get()

    XCTAssertNotNil(classA)
    XCTAssertNil(classA2)
  }

  func test_resolver_multi_deps_register_resolver_arg() {
    let resolverId = "TEST_RESOLVER"
    let resolver = Resolver(resolverId)

    resolver.register { ClassA() }
    resolver.register { ClassB(classA: $0.get()) }

    let classA: ClassA? = resolver.get()
    let classB: ClassB? = get()
    let classB2: ClassB? = resolver.get()

    XCTAssertNotNil(classA)
    XCTAssertNil(classB)
    XCTAssertNotNil(classB2)
  }

  func test_multiple_expects_register() {
    globalResolver.register(expects: [ClassAProtocol.self, ClassAProtocolB.self]) { ClassA() }

    let classA: ClassAProtocol? = get()
    let classA_2: ClassAProtocolB? = get()

    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
  }

  func test_multiple_expects_register_arg() {
    globalResolver.register(
      expects: [ClassAProtocol.self, ClassAProtocolB.self],
      arg1: String.self,
      arg2: Int.self
    ) { ClassA(name: $0, age: $1) }

    let name1 = "hello"
    let name2 = "hi"
    let age = 1
    let classA: ClassAProtocol? = get(name1, age)
    let classA_2: ClassAProtocolB? = get(name2, age)

    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
    XCTAssertEqual(classA?.name, name1)
    XCTAssertEqual(classA_2?.age, age)
  }

  func test_optional_args() {
    globalResolver.register(
      arg1: String.self,
      arg2: Int?.self
    ) { ClassA(name: $0, age: $1) }

    let name1 = "hello"
    let age1 = 1
    let classA: ClassA? = get()
    let classA_2: ClassA? = get(name1)
    let classA_3: ClassA? = get(name1, age1)

    XCTAssertNil(classA)
    XCTAssertNotNil(classA_2)
    XCTAssertNotNil(classA_3)
  }

  func test_subclassing() {
    let resolver = ResolverSubclass()
      .register(.single) { ClassA() }
      .register { ClassB(classA: $0.get()) }
      .register { ClassC(classA: $0.get(expect: ClassA.self), classB: $0.get()) }

    let classA: ClassA = resolver.get()
    let classB: ClassB = resolver.get()
    let classC: ClassC = resolver.get()

    XCTAssertEqual(classC.classA.name, classA.name)
    XCTAssertEqual(classC.classB.classA.id, classA.id)
    XCTAssertNotEqual(classC.classB.id, classB.id)
  }
  
  func test_quick_initailizer() {
    XCTAssertNotNil(ResolverSubclassSelfRegister.shared.get(expect: ClassA.self))
  }
  
  func test_different_thread_resolver() {
    let resolver = ResolverSubclass()
      
    _ = DispatchQueue(label: "thread1").sync {
      resolver.register { ClassA() }
    }
    _ = DispatchQueue(label: "thread2").sync {
      resolver.register { ClassB(classA: $0.get()) }
    }

    let classA: ClassA? = resolver.get()
    let classB: ClassB? = resolver.get()

    XCTAssertNotNil(classA)
    XCTAssertNotNil(classB)
  }
  
  func test_multiple_singles_same_resolver() {
    let resolver = ResolverSubclass()
      .register(.single) { ClassA() }
      .register(.single) { ClassB(classA: $0.get()) }

    let classA1: ClassA? = resolver.get()
    let classB1: ClassB? = resolver.get()
    let classA2: ClassA? = resolver.get()
    let classB2: ClassB? = resolver.get()
    
    XCTAssertNotNil(classA1)
    XCTAssertNotNil(classB1)
    XCTAssertNotNil(classA2)
    XCTAssertNotNil(classB2)
  }
  
  func test_resolver_local_scope() {
    let resolver = ResolverSubclass()
    resolver.register(.factory) { ClassA() }
    resolver.register(.single) { ClassB(classA: $0.get()) }
    
    let classA1: ClassA? = resolver.get(.single)
    let classA2: ClassA? = resolver.get(.single)
    let classA3: ClassA? = resolver.get(.factory)
    let classA4: ClassA? = resolver.get()
    let classB1: ClassB? = resolver.get()
    let classB2: ClassB? = resolver.get()
    let classB3: ClassB? = resolver.get(.factory)

    XCTAssertNotNil(classA2)
    XCTAssertNotNil(classA2)
    XCTAssertEqual(classA1?.id, classA2?.id)
    XCTAssertNotEqual(classA3?.id, classA1?.id)
    XCTAssertNotEqual(classA4?.id, classA1?.id)
    XCTAssertEqual(classB1?.id, classB2?.id)
    XCTAssertNotEqual(classB1?.id, classB3?.id)
  }
  
  func test_uregistering_deps() {
    let resolver = ResolverSubclass()
    resolver.register { ClassA() }
    
    let classA1: ClassA? = resolver.get()
    XCTAssertNotNil(classA1)
    
    resolver.unregister([ClassA.self])
    
    let classA2: ClassA? = resolver.get()
    XCTAssertNil(classA2)
  }
  
  func test_uregistering_deps_with_cache() {
    let resolver = ResolverSubclass()
    resolver.register(.single) { ClassA() }
    
    let classA1: ClassA? = resolver.get()
    XCTAssertNotNil(classA1)
    
    resolver.unregister([ClassA.self])
    
    let classA2: ClassA? = resolver.get()
    XCTAssertNil(classA2)
    
    resolver.register(.single) { ClassA() }
    
    let classA3: ClassA? = resolver.get()
    XCTAssertNotNil(classA3)
    XCTAssertEqual(classA1?.id, classA3?.id)
    XCTAssertNotEqual(classA1?.id, classA2?.id)
  }
  
  func test_dropping_deps_cached() {
    let resolver = ResolverSubclass()
    resolver.register(.single) { ClassA() }
    
    let classA1: ClassA? = resolver.get()
    
    XCTAssertNotNil(classA1)
    
    resolver.dropCached([ClassA.self])
    
    let classA2: ClassA? = resolver.get()
    
    XCTAssertNotNil(classA1)
    XCTAssertNotEqual(classA1?.id, classA2?.id)
  }
  
  func test_multi_dropping_deps_cached() {
    let resolver = ResolverSubclass()
    resolver.register(.single) { ClassA() }
    resolver.register { ClassB(classA: $0.get()) }
    
    let classA1: ClassA? = resolver.get()
    let classB1: ClassB? = resolver.get()
    
    XCTAssertNotNil(classA1)
    XCTAssertNotNil(classB1)
    
    resolver.dropCached([ClassB.self])
    
    let classA2: ClassA? = resolver.get()
    let classB2: ClassB? = resolver.get()
    
    XCTAssertNotNil(classA1)
    XCTAssertEqual(classA1?.id, classA2?.id)
    XCTAssertNotEqual(classB1?.id, classB2?.id)
    XCTAssertEqual(classB1?.classA.id, classB2?.classA.id)
  }
}
