
import Foundation

protocol BoxProtocol {
  var stringValue: String { get }
  var stringArgs: [String] { get }
  func scope() -> Resolver.Scope
  func value<_T, _A, _B, _C, _D>(
    arg1: _A,
    arg2: _B,
    arg3: _C,
    arg4: _D
  ) throws -> _T!
}

struct Box<T, R: ResolverProtocol, A, B, C, D>: BoxProtocol {
  enum Closure {
    case noargs(BoxClosureNoArg<T>)
    case arg1(BoxClosure1Arg<T, A>)
    case args2(BoxClosure2Arg<T, A, B>)
    case args3(BoxClosure3Arg<T, A, B, C>)
    case args4(BoxClosure4Arg<T, A, B, C, D>)
    
    case noargsR(BoxClosureNoArgR<T, R>)
    case arg1R(BoxClosure1ArgR<T, R, A>)
    case args2R(BoxClosure2ArgR<T, R, A, B>)
    case args3R(BoxClosure3ArgR<T, R, A, B, C>)
    case args4R(BoxClosure4ArgR<T, R, A, B, C, D>)
  }
  
  private let _scope: Resolver.Scope
  private let closure: Closure
  private let resolver: ResolverProtocol
  
  let stringValue = String(describing: T.self)
  let stringArgs = [A.self, B.self, C.self, D.self].map { String(describing: $0) }.filter { $0 != "()" }
  
  func scope() -> Resolver.Scope {
    _scope
  }

  public init(
    resolver: ResolverProtocol,
    scope: Resolver.Scope,
    closure: Closure
  ) {
    self.resolver = resolver
    self._scope = scope
    self.closure = closure
  }
  
  func value<_T, _A, _B, _C, _D>(
    arg1: _A,
    arg2: _B,
    arg3: _C,
    arg4: _D
  ) throws -> _T! {
    switch closure {
    case let .noargs(closure): return try closure() as? _T
    case let .arg1(closure):
      if let arg1 = arg1 as? A {
        return try closure(arg1) as? _T
      }
    case let .args2(closure):
      if let arg1 = arg1 as? A, let arg2 = arg2 as? B {
        return try closure(arg1, arg2) as? _T
      }
    case let .args3(closure):
      if let arg1 = arg1 as? A, let arg2 = arg2 as? B, let arg3 = arg3 as? C {
        return try closure(arg1, arg2, arg3) as? _T
      }
    case let .args4(closure):
      if let arg1 = arg1 as? A, let arg2 = arg2 as? B, let arg3 = arg3 as? C, let arg4 = arg4 as? D {
        return try closure(arg1, arg2, arg3, arg4) as? _T
      }
    case let .noargsR(closure):
      if let resolver = resolver as? R {
        return try closure(resolver) as? _T
      }
    case let .arg1R(closure):
      if let resolver = resolver as? R, let arg1 = arg1 as? A {
        return try closure(resolver, arg1) as? _T
      }
    case let .args2R(closure):
      if let resolver = resolver as? R, let arg1 = arg1 as? A, let arg2 = arg2 as? B {
        return try closure(resolver,arg1, arg2) as? _T
      }
    case let .args3R(closure):
      if let resolver = resolver as? R, let arg1 = arg1 as? A, let arg2 = arg2 as? B, let arg3 = arg3 as? C {
        return try closure(resolver, arg1, arg2, arg3) as? _T
      }
    case let .args4R(closure):
      if let resolver = resolver as? R, let arg1 = arg1 as? A, let arg2 = arg2 as? B, let arg3 = arg3 as? C, let arg4 = arg4 as? D {
        return try closure(resolver, arg1, arg2, arg3, arg4) as? _T
      }
    }
    return nil
  }

}

func getDependencyId(_ any: Any) -> String {
  return String(describing: type(of: any)).clean()
}
