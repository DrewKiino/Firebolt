
import Foundation

// MARK: - EXPECT ARGS+

extension Resolver {
  public func deregister<T>(_ object: T.Type) {
    let boxKey = getBoxKey(object.self).clean()
    coreInstance.removeBox(boxKey)
  }
  
  @discardableResult
  public func register<T>(
    _ scope: Scope = .factory,
    expect object: T.Type = T.self,
    closure: @escaping BoxClosureNoArg<T>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    coreInstance.setBox(boxKey, box: Box<T, Void, Void, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .noargs(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey)")
    return self
  }
  
  @discardableResult
  public func register<T, A>(
    _ scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    closure: @escaping BoxClosure1Arg<T, A>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    coreInstance.setBox(boxKey, box: Box<T?, A, Void, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .arg1(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B>(
    scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    closure: @escaping BoxClosure2Arg<T, A, B>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    let box = coreInstance.setBox(boxKey, box: Box<T?, A, B, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .args2(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey) with expected args \(box.stringArgs)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C>(
    scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    closure: @escaping BoxClosure3Arg<T, A, B, C>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    coreInstance.setBox(boxKey, box: Box<T, A, B, C, Void>(
      resolver: self,
      scope: scope,
      closure: .args3(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C, D>(
    scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    arg4: D.Type,
    closure: @escaping BoxClosure4Arg<T, A, B, C, D>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    coreInstance.setBox(boxKey, box: Box<T, A, B, C, D>(
      resolver: self,
      scope: scope,
      closure: .args4(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey) with expected argument \(arg1)")
    return self
  }
}

// MARK: - EXPECT+ ARGS+

extension Resolver {
  @discardableResult
  public func register<T>(
    _ scope: Scope = .factory,
    expects objects: [Any.Type],
    closure: @escaping BoxClosureNoArg<T>
  ) -> Self {
    for object in objects {
      let boxKey = getBoxKey(object.self).clean()
      coreInstance.setBox(boxKey, box: Box<T, Void, Void, Void, Void>(
        resolver: self,
        scope: scope,
        closure: .noargs(closure)
      ))
      logger(.info, "\(resolverId) - registered \(boxKey)")
    }
    return self
  }

  @discardableResult
  public func register<T, A>(
    _ scope: Scope = .factory,
    expects objects: [Any.Type],
    arg1: A.Type,
    closure: @escaping BoxClosure1Arg<T, A>
  ) -> Self {
    for object in objects {
      let boxKey = getBoxKey(object.self).clean()
      coreInstance.setBox(boxKey, box: Box<T?, A, Void, Void, Void>(
        resolver: self,
        scope: scope,
        closure: .arg1(closure)
      ))
      logger(.info, "\(resolverId) - registered \(boxKey) with expected argument \(arg1)")
    }
    return self
  }
  
  @discardableResult
  public func register<T, A, B>(
    scope: Scope = .factory,
    expects objects: [Any.Type],
    arg1: A.Type,
    arg2: B.Type,
    closure: @escaping BoxClosure2Arg<T, A, B>
  ) -> Self {
    for object in objects {
      let boxKey = getBoxKey(object.self).clean()
      let box = coreInstance.setBox(boxKey, box: Box<T?, A, B, Void, Void>(
        resolver: self,
        scope: scope,
        closure: .args2(closure)
      ))
      logger(.info, "\(resolverId) - registered \(boxKey) with expected args \(box.stringArgs)")
    }
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C>(
    scope: Scope = .factory,
    expects objects: [Any.Type],
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    closure: @escaping BoxClosure3Arg<T, A, B, C>
  ) -> Self {
    for object in objects {
      let boxKey = getBoxKey(object.self).clean()
      coreInstance.setBox(boxKey, box: Box<T, A, B, C, Void>(
        resolver: self,
        scope: scope,
        closure: .args3(closure)
      ))
      logger(.info, "\(resolverId) - registered \(boxKey) with expected argument \(arg1)")
    }
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C, D>(
    scope: Scope = .factory,
    expects objects: [Any.Type],
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    arg4: D.Type,
    closure: @escaping BoxClosure4Arg<T, A, B, C, D>
  ) -> Self {
    for object in objects {
      let boxKey = getBoxKey(object.self).clean()
      coreInstance.setBox(boxKey, box: Box<T, A, B, C, D>(
        resolver: self,
        scope: scope,
        closure: .args4(closure)
      ))
      logger(.info, "\(resolverId) - registered \(boxKey) with expected argument \(arg1)")
    }
    return self
  }
}

// MARK: - EXPECT ARGS+ RESOLVER

extension Resolver {
  @discardableResult
  public func register<T>(
    _ scope: Scope = .factory,
    expect object: T.Type = T.self,
    closure: @escaping BoxClosureNoArgR<T>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    coreInstance.setBox(boxKey, box: Box<T, Void, Void, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .noargsR(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey)")
    return self
  }
  
  @discardableResult
  public func register<T, A>(
    _ scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    closure: @escaping BoxClosure1ArgR<T, A>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    coreInstance.setBox(boxKey, box: Box<T?, A, Void, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .arg1R(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B>(
    scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    closure: @escaping BoxClosure2ArgR<T, A, B>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    let box = coreInstance.setBox(boxKey, box: Box<T?, A, B, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .args2R(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey) with expected args \(box.stringArgs)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C>(
    scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    closure: @escaping BoxClosure3ArgR<T, A, B, C>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    coreInstance.setBox(boxKey, box: Box<T, A, B, C, Void>(
      resolver: self,
      scope: scope,
      closure: .args3R(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C, D>(
    scope: Scope = .factory,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    arg4: D.Type,
    closure: @escaping BoxClosure4ArgR<T, A, B, C, D>
  ) -> Self {
    let boxKey = getBoxKey(object.self).clean()
    coreInstance.setBox(boxKey, box: Box<T, A, B, C, D>(
      resolver: self,
      scope: scope,
      closure: .args4R(closure)
    ))
    logger(.info, "\(resolverId) - registered \(boxKey) with expected argument \(arg1)")
    return self
  }
}

// MARK: - EXPECT+ ARGS+ RESOLVER
