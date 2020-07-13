# Firebolt <img src="Assets/firebolt.png" width="32"> 

**Firebolt** is a dependency injection framework written for `Swift`. Inspired by `Kotlin` [Koin](https://insert-koin.io/). This framework is meant to be lightweight and unopinionated by design with resolutions working simply by good old functional programming.

## Contributions
`Firebolt` is an open-source project, feel free to contact me if you want to help contribute to this codebase. You can also do a pull-request or open up issues.

## Installation

### Cocoapods

`Firebolt` is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Firebolt'
```
### Swift Package Manager

```yml
url: https://github.com/DrewKiino/Firebolt.git
from: 0.3.6
```

## Documentation
* [Usage](#usage)
* [Scope](#scope)
* [Arguments](#arguments)
* [Protocol Conformance](#protocol-conformance)
* [Thread Safety](#thread-safety)
* [Global Resolver](#global-resolver)
* [Multiple Resolvers](#multiple-resolvers)
* [Subclassing Resolvers](#subclassing-resolvers)
* [Unregister Dependencies](#unregister-dependencies)
* [Storyboard Resolution](#storyboard-resolution)
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

Singleton resolutions also apply to protocols of concrete classes as well.
```swift
resolver.register(.single, expect: ClassAProtocol.self) { ClassA() }

let classA1: ClassAProtocol = get()
let classA2: ClassAProtocol = get()

// Both ClassA1 and ClassA2 are resolved from the same concrete instance
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
resolver.register(arg1: String.self) { ClassD(environment: $0) }
```
Then you can pass in the argument afterwards.
```swift
let classD: ClassD = get("stage")
```

You can pass in multiple arguments as well.
```swift
resolver.register(arg1: String.self, arg2: Int.self) { ClassD(environment: $0, timestamp: $1) }

let classD: ClassD = get("stage", 1200)
```

You can also pass in optionals like so.
```swift
class ClassE { init(value: String?) {} }

let resolver = Resolver()
resolver.register(arg1: String?.self) { ClassE($0) }

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

### Thread Safety

`Firebolt` has a internal global queue that makes sure dependencies and resolvers are registered/unregistered in the same sequence. 

### Global Resolver

Normally, if you initialze a `Resolver` without a resolver identifier passed in, you will get the `GlobalResolver`. You can register and unregister dependencies with this special resolver as well as having resolutions without much work for your application. 
```swift
let resolver = Resolver() // <-- GlobalResolver created

resolver.register { ClassA() }
```
You can then globally inject dependencies without specifying a Resolver identifier.
```swift
// property scoped in another instance of the application 
// will resolve automatically for you.
let classA: ClassA = get()
```

Although you can pass in a `resolverId` if you want global resolution to a specific `Resolver` regardless as the `GlobalResolver` is shared across all instances naturally.

```swift
let classA: ClassA = get("Resolver_1")
```

### Multiple Resolvers 

If you want to keep dependencies separate you can instantiate multiple resolvers with each having their own scope.

When you initialize a `Resolver` you have to pass in a `resolverId`, Firebolt then registers this resolver in a cache. 

1. Instantiate a `Resolver` with a unique identifier.

```swift
let resolver1 = Resolver("Resolver_1")
resolver1.register { ClassA() }

let resolver2 = Resolver("Resolver_2")
resolver2.register { ClassA() }

// make sure to resolve using the Resolver itself using lamba
resolver2.register { ClassB(classA: $0.get()) }
```

2. Then inject by referencing by their respective resolvers.

```swift
// resolves to `nil` because Resolver_1 never registered ClassB
let classB: ClassB = resolver1.get()

// resolves to ClassB 
let classB: ClassB = resolver2.get()
```

Here is an example of using a `Resolver` via an `Interface` like design.

```swift
let resolver: Resolver
init(resolver: Resolver) { self.resolver = resolver }

func viewDidLoad() {
    let classB: ClassB = resolver.get()
}
```
Objects not registered by the resolver won't be shared by other resolvers. This includes objects registered as `.single` as well unless they are registered by the `GlobalResolver` itself in which they become a true `Singleton`.

If you initailize two resolvers of the same identifier, they both will share the same cache of dependencies.

```swift
let resolverA = Resolver("SAME_IDENTIFIER")
resolverA.register { ClassA() }

let resolverB = Resolver("SAME_IDENTIFIER")

// This will successfully resolve since ResolverB shares the same 
// identifier as ResolverA - thus the same cache of dependencies.
let classA: ClassA = resolverB.get() 

```

### Subclassing Resolvers

Resolvers are subclassable if you feel the need to create your own kind of a `Resolver` ex: `MyAppResolver`. 

It is important that you pass in your own `resolverId` through an initializer witin your subclass. If you don't, your subclass will inheritely be a `GlobalResolver` since a standalone `Resolver` class with no identifier will essentiually access the singleton itself.

```swift
class MyAppResolver: Resolver {
    init() {
        super.init("MyAppResolver")
    }
}

let myResolver = MyAppResolver()
myResolver.register { ClassA() }

// this will work
let classA: ClassA = myResolver.get()

// this will also work
let classA: ClassA = get(resolverId: "MyAppResolver")

// this will fail
let classA: ClassA = get()
```

### Unregister Dependencies

You can unregister dependencies like so.

```swift
resolver.register { ClassA() }

let classA: ClassA? = get() // will return ClassA

resolver.unregister(ClassA.self)

let classA: ClassA? = get() // will return nil
```

### Storyboard Resolution

`Firebolt` can be used to resolve storyboards as well. Given this example,

```swift
// There are multiple ways to initialize a storyboard view code but in this case
// we will use a static initializer for the sake of allowing external parameters
class ViewController {
    class func initialize(userManager: UserManager): SecondViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: "ViewController") as! ViewController 
    }
}

// .. then register
resolver
  .register { UserManager() }
  .register { ViewController.initialize(userManager: get()) }
  
// ... when resolving it
let vc: ViewController = get()

// ... or if you're using a container based approach
let vc: ViewController = someResolver.get()
```

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

## Author

Andrew Aquino, andrewaquino118@gmail.com

## License

**Firebolt** is available under the MIT license. See the LICENSE file for more info.







