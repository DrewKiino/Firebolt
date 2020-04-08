# Firebolt <img src="Firebolt/Assets/firebolt.png" width="32"> 

**Firebolt** is a dependency injection framework written for `Swift`. Inspired by `Kotlin` [Koin](https://insert-koin.io/). This framework is meant to be lightweight and unopinionated by design with resolutions working simply by good old functional programming.

## Contributions
`Firebolt` is an open-source project, feel free to contact me if you want to help contribute to this codebase. You can also do a pull-request or open up issues.

## Author

Andrew Aquino, andrewaquino118@gmail.com

## Documentation
* [Usage](#usage)
* [Scope](#scope)
* [Arguments](#arguments)
* [Protocol Conformance](#protocol-conformance)
* [Multiple Resolvers](#multiple-resolvers)
* [Examples](#examples)

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
let classD: ClassD = get("stage")
```

You can pass in multiple arguments as well.
```swift
resolver.register(arg1: String.self, arg2: Int.self) { 
    ClassD(environment: $0, timestamp: $1) 
}

let classD: ClassD = get("stage", 1200)
```

You can also pass in optionals like so.
```swift
class ClassE { init(value: String?) {} }

let resolver = Resolver()
resolver.register(arg1: Optional<String>.self) { ClassE($0) }

// no arguments tells the resolver to pass nil instead
let classE: ClassE = get() 
let classE: ClassE = get("SOME_VALUE")
```

For shared non-registered arguments between dependencies, you can pass in arguments from within the `register` block using the upstream argument themselves.
```swift
let resolver = Resolver()

class ClassC {
    init(classA: ClassA, classB: ClassB) {}
}

resolver
    .register(arg1: ClassA.self) { ClassB(classA: $0) }
    .register(arg1: ClassA.self) { 
        // ClassA is now shared between ClassB and ClassC
        // without registration
        ClassC(classA: $0, classB: get($0)) 
    }

// Then call them like so
let classA: ClassA = ClassA()
let classC: ClassC = get(classA)
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

class ClassA: ClassAVariantA, ClassAVariantB { 
    func foo() {} 
    func bar() {}
}

let resolver = Resolver()

resolver.register { ClassA() }

// multiple resolutions using the same concrete type with the expect qualifier
let variantA: ClassAVaraintA = get(expect: ClassA.self)
let variantB: ClassAVaraintB = get(expect: ClassA.self)
```

Or using a different method, passing multiple expects for the same concrete class.
```swift
let resolver = Resolver()

resolver.register(expects: [ClassAVaraintA.self, ClassAVaraintB.self]) { ClassA() }

let classA: ClassAVaraintA? = get()
let classA: ClassAVaraintB? = get()
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
let classB: ClassB = get(resolverId: "Resolver_1") 

// resolves to ClassB 
let classB: ClassB = get(resolverId: "Resolver_2") 
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

## Installation

Resolver is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Firebolt'
```

## License

**Resolver** is available under the MIT license. See the LICENSE file for more info.







