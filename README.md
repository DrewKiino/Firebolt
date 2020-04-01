# Firebolt

**Firebolt** is a dependency injection framework written for `Swift`. Inspired by `Kotlin` [Koin](https://insert-koin.io/). This framework is meant to be lightweight and unopinionated by design with resolutions working simply by good old functional programming.

<!-- [![CI Status](https://img.shields.io/travis/drewkiino/Firebolt.svg?style=flat)](https://travis-ci.org/drewkiino/Firebolt) -->[![Version](https://img.shields.io/cocoapods/v/Firebolt.svg?style=flat)](https://cocoapods.org/pods/Firebolt) [![License](https://img.shields.io/cocoapods/l/Firebolt.svg?style=flat)](https://cocoapods.org/pods/Firebolt) [![Platform](https://img.shields.io/cocoapods/p/Firebolt.svg?style=flat)](https://cocoapods.org/pods/Firebolt)

## Documentation
* [Usage](#usage)
* [Scope](#scope)
* [Arguments](#arguments)
* [Protocol Conformance](#protocol-conformance)
* [Multiple Resolvers](#multiple-resolvers)
* [Examples](#examples)

## Installation

Resolver is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Firebolt'
```

## Author

Andrew Aquino, andrewaquino118@gmail.com

### Usage

1. Instantiate a `Resolver`
```swift
let resolver = Resolver()
```
2. Register dependencies.
```swift
class ClassA {}

resolver.register { ClassA() }
```
3. Use the `get()` qualifier to resolve inner dependencies.
```swift
class ClassA {}
class ClassB { init(classA: ClassA) }
 
try resolver
    .register { ClassA() }
    .register { ClassB(classA: get()) } // <-- get() qualifier
```
4. Start coding with dependency injection using the `get()` keyword.
```swift
let classA: ClassA = get()
let classB: ClassB = get()
```

### Scope
You can pass in a `scope` qualifier during registration to tell the `Resolver` how you want to instance to be resolved. 

The current supported forms of `scope` are:
```swift
enum Scope {
    case single // <- the same instance is resolved each time
    case factory // <- unique instances are resolved each time
}
```

You can set scope like this.
```swift
resolver.register(.single) { ClassA() } // scope is now .single
resolver.register(.factory) { ClassA() } 
resolver.register { ClassA() } // .factory is also the default

// now these two are of the same instances 
let classA: ClassA = get() 
let classA: ClassA = get()
```

### Arguments

You can pass in arguments during registration like so.
```swift
let resolver = Resolver()
let environment: String = "stage"

reasolver.register { ClassD(environment: environment, classA: get()) }
```

If the arguments need to be passed in at the call site. You can specify the expected type during registration.
```swift
reasolver.register(arg1: String.self) { ClassD(environment: $0) }
```
Then you can pass in the argument afterwards.
```swift
let classD: ClassD = get(environment: "stage")
```

You can pass in multiple arguments as well.
```swift
resolver.register(arg1: String.self, arg2: Int.self) { 
    ClassD(environment: $0, timestamp: $1) 
}

let classD: ClassD = get(arg1: "stage", arg2: 1200)
```

For shared non-registered arguments between dependencies, you can pass in arguments from within the `register` block using the upstream argument themselves.
```swift
let resolver = Resolver()

resolver
    .register(arg1: ClassA.self) { ClassB(classA: $0) }
    .register(arg1: ClassA.self) { 
        // ClassA is now shared between ClassB and ClassC
        // without registration
        ClassC(environment: $0), classB: get(arg1: $0)) 
    }

// Then call it like so
let classC: ClassC = get(arg1: ClassA())
```

### Protocol Conformance 
Protocol conformance is also supported by the `Resolver`. Let's say you want to have a `ClassA` protocol and a `ClassAImpl` concrete type registered, you can use the `expect` argument.

```swift
protocol ClassA { func foo() }

class ClassAImpl: ClassA { func foo() {} }

let resolver = Resolver()

resolver.register(expect: ClassA.self) { ClassAImpl() }
```
Then when calling it in the callsite.
```swift
let classA: ClassA = get() // <- ClassAImpl will be returned
```

You are also able to have support for multiple protocols for the same concrete type.
```swift
protocol ClassAVariantA { func foo() }
protocol ClassAVariantB { func bar() }

class ClassAImpl: ClassAVariantA, ClassAVariantB { 
    func foo() {} 
    func bar() {}
}

let resolver = Resolver()

resolver.register(expect: ClassA.self) { ClassAImpl() }

// mulitple resolutions using the same concrete type
let variantA: ClassAVaraintA = get()
let variantB: ClassAVaraintB = get()
```

If there are dependencies that require protocol conformance but you are only supporting a concrete class you can do the following:

```swift
class ClassA: ClassAVariantA {}

class ClassB { init(classAVariant: ClassAVariantA) {} }

let resolver = Resolver()

resolver
    .register { ClassA() }
    .register { ClassB(classAVariant: get(expect: ClassA.self)) }

// works
let classB: ClassB = get()
```

This works because `ClassA` is registered in the dependency scope
but we are able to cast it to the expected type `ClassAVaraintA` by using the `get()` qualifier and the `expect` argument passed in during the callsite. 

### Multiple Resolvers 
Normally, if you initialze a `Resolver` without a resolver identifier passed in, you will get the `GlobalResolver`.
```swift
let resolver = Resolver() // <- GlobalResolver created
```
This means that you can inject dependencies without specifying the resolver identifier.
```swift
let classA: ClassA = get()
```
However, if you want to keep dependencies separate:
1. You can instantiate multiple resolvers. Each having their own scope.
```swift
let resolver1 = Resolver("Resolver_1")
resolver1.register { ClassA() }

let resolver2 = Resolver("Resolver_2")
resolver2.register { ClassA() }
resolver2.register { ClassB() }
```
2. Then inject by identifying the resolver. 
```swift
// resolves to `nil` because Resolver_1 never registered ClassB
let classB: ClassB = get("Resolver_1") 

// resolves to ClassB 
let classB: ClassB = get("Resolver_2") 
```
3. You can also call `get()` directly by the resolver if you want to go through an `Interface` like design.
```swift
let resolver: Resolver
init(resolver: Resolver) { self.resolver = resolver }

func viewDidLoad() {
    let classB: ClassB = resolver.get()
}
```
Objects not registered by the resolver won't be shared by other resolvers. This includes objects registered as `.single` as well unless the they are registered by the `GlobalResolver` itself in which they become a true `Singleton`.

### Examples 
**Application Architecture**
```swift
// UserManager.swift
class UserManager {}

// ViewController.swift
class ViewController: UIViewController {
    public init(userManager: UserManager) {}
}

// AppDelegate.swift
class AppDelegate {

  let resolver = Resolver()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    resolver.register { UserManager() }
    resolver.register { ViewController(userManager: get()) }

    let viewController: ViewController = get()
    window?.rootViewController = viewController
  }
}
```

## License

**Resolver** is available under the MIT license. See the LICENSE file for more info.







