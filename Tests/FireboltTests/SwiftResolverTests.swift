
import XCTest
@testable import FireboltSwift

final class SwiftResolverTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
    Resolver.global.unregisterAllDependencies()
    Resolver.global.dropAllCachedDependencies()
  }

  func test_injection_factory() {
    let a = ClassA()
    Resolver.global.register { a }
    let classA: ClassA = get()
    XCTAssertEqual(a.id, classA.id)
  }
  
  func test_injection_factory_2() {
    Resolver.global.register { ClassA() }
    Resolver.global.register(expect: ClassB.self) { ClassB(classA: get()) }
    let classA: ClassA? = get()
    let classB: ClassB? = get()
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classB)
  }

  func test_injection_protocol_fail() {
    Resolver.global.register { ClassA() }
    let classA: ClassAProtocol? = get()
    XCTAssertNil(classA)
  }

  func test_injection_protocol_fail2() {
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    XCTAssertNil(classA)
  }

  func test_injection_protocol() {
    Resolver.global.register { ClassA() }
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    XCTAssertNotNil(classA)
  }

  func test_injection_protocol_register() {
    Resolver.global.register(expect: ClassAProtocol.self) { ClassA() }
    let classA: ClassAProtocol? = get()
    let classA_2: ClassA? = get()
    XCTAssertNotNil(classA)
    XCTAssertNil(classA_2)
  }

  func test_injection_double_protocol() {
    Resolver.global.register { ClassA() }
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    let classA_B: ClassAProtocolB? = get(expect: ClassA.self)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_B)
  }

  func test_injection_double_protocol_impl() {
    Resolver.global.register(expect: ClassE.self) { ClassEImpl() }
    let classE: ClassEProtocol? = get(expect: ClassE.self)
    let classE_B: ClassEProtocolB? = get(expect: ClassE.self)
    XCTAssertNotNil(classE)
    XCTAssertNotNil(classE_B)
  }

  func test_injection_double_protocol_concrete() {
    Resolver.global.register { ClassA() }
    let classA: ClassAProtocol? = get(expect: ClassA.self)
    let classA_B: ClassAProtocolB? = get(expect: ClassA.self)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_B)
  }

  func test_injection_protocol_impl() {
    let name = "Hello"
    Resolver.global
      .register { ClassA() }
      .register { ClassB(classA: get()) }
      .register { ClassC(classA: get(expect: ClassA.self), classB: get()) }
      .register(expect: ClassD.self) { ClassDImpl(name: name, classC: get()) }
    let classD: ClassD = get()
    XCTAssertNotNil(classD)
    XCTAssertEqual(classD.name, name)
  }

  func test_injection_protocol_multiple() {
    Resolver.global.register { ClassA() }

    let classA: ClassAProtocol = get(expect: ClassA.self)
    let classA_2: ClassAProtocolB = get(expect: ClassA.self)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
  }

  func test_injection_singleton() {
    let a = ClassA()
    Resolver.global.register(.single) { a }
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
    Resolver.global.register(.single, arg1: String.self) { ClassA(name: $0) }
    let classA: ClassA? = get()
    XCTAssertNil(classA)
  }

  func test_injection_wrongdeps_fail() {
    Resolver.global.register { ClassA() }
    let classB: ClassB? = get()
    XCTAssertNil(classB)
  }

  func test_injection_1arg_optional_default_singleton() {
    Resolver.global.register(.single, arg1: String?.self) { ClassA(name: $0) }
    let name = "hello"
    let classA: ClassA? = get()
    let classA_2: ClassA? = get(name)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
    XCTAssertNotEqual(classA_2?.name, name)
  }

  func test_injection_1arg_optional_factory() {
    Resolver.global.register(.factory, arg1: String?.self) { ClassA(name: $0) }
    let name = "hello"
    let classA: ClassA? = get()
    let classA_2: ClassA? = get(name)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
    XCTAssertEqual(classA_2?.name, name)
  }

  func test_injection_1arg() {
    Resolver.global.register(.single, arg1: String.self) { ClassA(name: $0) }
    let newName = "Hi"
    let classA: ClassA? = get(newName)
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, newName)
  }

  func test_injection_1arg_optional() {
    Resolver.global.register(.single, arg1: String?.self) { ClassA(name: $0) }
    let classA: ClassA? = get(String?.none)
    XCTAssertNotNil(classA)
    XCTAssertEqual(classA?.name, noName)
  }

  func test_injection_2arg_optional() {
    Resolver.global.register(arg1: String?.self, arg2: Int?.self) {
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
    Resolver.global.register(arg1: String?.self, arg2: Int?.self) {
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
    Resolver.global.register(.single) { ClassA() }
    let classA: ClassA = get()
    let classA_2: ClassA = get()

    XCTAssertEqual(classA.id, classA_2.id)
  }

  func test_2injection_factory() {
    Resolver.global.register(.factory) { ClassA() }
    let classA: ClassA = get()
    let classA_2: ClassA = get()

    XCTAssertNotEqual(classA.id, classA_2.id)
  }

  func test_1deps_factory() {
    Resolver.global.register(.factory) { ClassA() }
        .register { ClassB(classA: get()) }
    let classA: ClassA = get()
    let classB: ClassB = get()

    XCTAssertNotEqual(classB.classA.id, classA.id)
  }

  func test_1deps_singleton( ){
    Resolver.global.register(.single) { ClassA() }
        .register { ClassB(classA: get()) }
    let classA: ClassA = get()
    let classB: ClassB = get()

    XCTAssertEqual(classA.id, classB.classA.id)
  }

  func test_nested_singleton() {
    Resolver.global
      .register { ClassA() }
      .register(.factory) { ClassB(classA: get()) }
      .register(.factory) { ClassC(classA: get(expect: ClassA.self), classB: get()) }
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

    Resolver.global.register { ClassA() }

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
    resolver.register { (r: Resolver) in ClassB(classA: r.get()) }

    let classA: ClassA? = resolver.get()
    let classB: ClassB? = get()
    let classB2: ClassB? = resolver.get()

    XCTAssertNotNil(classA)
    XCTAssertNil(classB)
    XCTAssertNotNil(classB2)
  }
  
  func test_multiple_expects_register_single() {
    let resolver = MockResolver { resolver in
      resolver.register(
        .single,
        expects: [ClassAProtocol.self, ClassAProtocolB.self]
      ) {
        (_: MockResolver) in ClassA()
      }
    }
    
    let classA: ClassAProtocol? = resolver.get()
    let classA_2: ClassAProtocolB? = resolver.get()

    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
    XCTAssertEqual(classA?.id, classA_2?.id)
  }

  func test_multiple_expects_register_factory() {
    let resolver = MockResolver { resolver in
      resolver.register(
        .factory,
        expects: [ClassAProtocol.self, ClassAProtocolB.self]
      ) { (_: MockResolver) in
        ClassA()
      }
    }

    let classA: ClassAProtocol? = resolver.get()
    let classA_2: ClassAProtocolB? = resolver.get()

    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA_2)
    XCTAssertNotEqual(classA?.id, classA_2?.id)
  }

  func test_multiple_expects_register_arg() {
    Resolver.global.register(
      expects: [ClassAProtocol.self, ClassAProtocolB.self],
      arg1: String.self,
      arg2: Int.self
    ) { (_: Resolver, a, b) in
      ClassA(name: a, age: b)
    }

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

  func test_optional_args_factory() {
    Resolver.global.register(
      scope: .factory,
      arg1: String.self,
      arg2: Int?.self
    ) { (_: Resolver, a, b) in
      ClassA(name: a, age: b)
    }

    let name1 = "hello"
    let age1 = 1
    let classA: ClassA? = get()
    let classA_2: ClassA? = get(name1)
    let classA_3: ClassA? = get(name1, age1)

    XCTAssertNil(classA)
    XCTAssertNotNil(classA_2)
    XCTAssertNotNil(classA_3)
  }

  func test_subclassing_factory() {
    let resolver = ResolverSubclass()
      .register { ClassA() }
      .register(.factory) { (r: ResolverSubclass) in ClassB(classA: r.get()) }
      .register(.factory) { (r: ResolverSubclass) in ClassC(classA: r.get(expect: ClassA.self), classB: r.get()) }

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
      resolver.register { (r: ResolverSubclass) in ClassB(classA: r.get()) }
    }

    let classA: ClassA? = resolver.get()
    let classB: ClassB? = resolver.get()

    XCTAssertNotNil(classA)
    XCTAssertNotNil(classB)
  }
  
  func test_multiple_singles_same_resolver() {
    let resolver = ResolverSubclass()
      .register(.single) { ClassA() }
      .register(.single) { (r: ResolverSubclass) in ClassB(classA: r.get()) }

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
    resolver.register(.single) { (r: ResolverSubclass) in ClassB(classA: r.get()) }
    
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
    resolver.register(.factory) { (r: ResolverSubclass) in ClassB(classA: r.get()) }
    
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
  
  func test_subclass_with_protocol() {
    let resolver = ResolverSubclass()
    resolver.register(.single, expect: ClassAProtocol.self) { ClassA() }
    let classA: ClassAProtocol? = resolver.get()
    let classA2: ClassAProtocol? = resolver.get()
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA2)
    XCTAssertEqual(classA?.id, classA2?.id)
  }
  
  func test_protocol_subclass_with_protocol() {
    let resolver: ResolverProtocol = ResolverSubclass()
    resolver.register(.single, expect: ClassAProtocol.self) { ClassA( )}
    let classA: ClassAProtocol? = resolver.get()
    let classA2: ClassAProtocol? = resolver.get(expect: ClassAProtocol.self)
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classA2)
    XCTAssertEqual(classA?.id, classA2?.id)
  }
  
  @available(OSX 10.15.0, *)
  func test_associative_protocol_deps() {
    let resolver = ResolverSubclass()
    resolver.register { UniqueClassA() }
    resolver.register(.factory) { (r: ResolverSubclass) in UniqueClassB(classA: r.get()) }
    
    let someClass1: some AssociativeProtocol = resolver.get(expect: UniqueClassA.self)
    let someClass2: some AssociativeProtocol = resolver.get(expect: UniqueClassB.self)

    XCTAssertNotNil(someClass1)
    XCTAssertNotNil(someClass2)

    let valueA: String? = someClass1.getValue() as? String
    let valueB: Int? = someClass2.getValue() as? Int
    
    XCTAssertEqual(valueA, "hello")
    XCTAssertEqual(valueB, 1)
    
    let classA: UniqueClassA? = resolver.get(expect: UniqueClassA.self)
    let classB: UniqueClassB? = resolver.get(expect: UniqueClassB.self)

    XCTAssertNotNil(classA)
    XCTAssertNotNil(classB)
    
    XCTAssertEqual(someClass1.id, classA?.id)
    XCTAssertNotEqual(someClass2.id, classB?.id)
    XCTAssertEqual(someClass1.id, classB?.classA.id)
  }
  
  func test_register_expects() {
    let resolver: ResolverProtocol = ResolverSubclass()
    resolver.register(.single, expects: [ClassAProtocol.self, ClassAProtocolB.self]) { (resolver: ResolverSubclass) in
      ClassA()
    }
    let classA: ClassAProtocol? = resolver.get()
    let classAB: ClassAProtocolB? = resolver.get()
    XCTAssertNotNil(classA)
    XCTAssertNotNil(classAB)
    XCTAssertEqual(classA?.id, classAB?.id)
  }

}
