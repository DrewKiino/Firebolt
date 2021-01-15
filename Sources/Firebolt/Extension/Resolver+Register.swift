
import Foundation

// MARK: - EXPECT ARGS+

extension Resolver {
  @discardableResult
  public func register<T>(
    _ scope: Scope = .single,
    expect object: T.Type = T.self,
    closure: @escaping BoxClosureNoArg<T>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    coreInstance.setBox(dependencyId, box: Box<T, Self, Void, Void, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .noargs(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId)")
    return self
  }
  
  @discardableResult
  public func register<T, A>(
    _ scope: Scope = .single,
    expect object: T.Type = T.self,
    arg1: A.Type,
    closure: @escaping BoxClosure1Arg<T, A>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    coreInstance.setBox(dependencyId, box: Box<T?, Self, A, Void, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .arg1(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B>(
    scope: Scope = .single,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    closure: @escaping BoxClosure2Arg<T, A, B>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    let box = coreInstance.setBox(dependencyId, box: Box<T?, Self, A, B, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .args2(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId) with expected args \(box.stringArgs)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C>(
    scope: Scope = .single,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    closure: @escaping BoxClosure3Arg<T, A, B, C>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    coreInstance.setBox(dependencyId, box: Box<T, Self, A, B, C, Void>(
      resolver: self,
      scope: scope,
      closure: .args3(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C, D>(
    scope: Scope = .single,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    arg4: D.Type,
    closure: @escaping BoxClosure4Arg<T, A, B, C, D>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    coreInstance.setBox(dependencyId, box: Box<T, Self, A, B, C, D>(
      resolver: self,
      scope: scope,
      closure: .args4(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId) with expected argument \(arg1)")
    return self
  }
}

// MARK: - EXPECT+ ARGS+

extension Resolver {
  @discardableResult
  public func register<T>(
    _ scope: Scope = .single,
    expects objects: [Any.Type],
    closure: @escaping BoxClosureNoArg<T>
  ) -> Self {
    for object in objects {
      let dependencyId = getDependencyId(object.self).clean()
      coreInstance.setBox(dependencyId, box: Box<T, Self, Void, Void, Void, Void>(
        resolver: self,
        scope: scope,
        closure: .noargs(closure)
      ))
      logger(.info, "\(resolverId) - registered \(dependencyId)")
    }
    return self
  }

  @discardableResult
  public func register<T, A>(
    _ scope: Scope = .single,
    expects objects: [Any.Type],
    arg1: A.Type,
    closure: @escaping BoxClosure1Arg<T, A>
  ) -> Self {
    for object in objects {
      let dependencyId = getDependencyId(object.self).clean()
      coreInstance.setBox(dependencyId, box: Box<T?, Self, A, Void, Void, Void>(
        resolver: self,
        scope: scope,
        closure: .arg1(closure)
      ))
      logger(.info, "\(resolverId) - registered \(dependencyId) with expected argument \(arg1)")
    }
    return self
  }
  
  @discardableResult
  public func register<T, A, B>(
    scope: Scope = .single,
    expects objects: [Any.Type],
    arg1: A.Type,
    arg2: B.Type,
    closure: @escaping BoxClosure2Arg<T, A, B>
  ) -> Self {
    for object in objects {
      let dependencyId = getDependencyId(object.self).clean()
      let box = coreInstance.setBox(dependencyId, box: Box<T?, Self, A, B, Void, Void>(
        resolver: self,
        scope: scope,
        closure: .args2(closure)
      ))
      logger(.info, "\(resolverId) - registered \(dependencyId) with expected args \(box.stringArgs)")
    }
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C>(
    scope: Scope = .single,
    expects objects: [Any.Type],
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    closure: @escaping BoxClosure3Arg<T, A, B, C>
  ) -> Self {
    for object in objects {
      let dependencyId = getDependencyId(object.self).clean()
      coreInstance.setBox(dependencyId, box: Box<T, Self, A, B, C, Void>(
        resolver: self,
        scope: scope,
        closure: .args3(closure)
      ))
      logger(.info, "\(resolverId) - registered \(dependencyId) with expected argument \(arg1)")
    }
    return self
  }
  
  @discardableResult
  public func register<T, A, B, C, D>(
    scope: Scope = .single,
    expects objects: [Any.Type],
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    arg4: D.Type,
    closure: @escaping BoxClosure4Arg<T, A, B, C, D>
  ) -> Self {
    for object in objects {
      let dependencyId = getDependencyId(object.self).clean()
      coreInstance.setBox(dependencyId, box: Box<T, Self, A, B, C, D>(
        resolver: self,
        scope: scope,
        closure: .args4(closure)
      ))
      logger(.info, "\(resolverId) - registered \(dependencyId) with expected argument \(arg1)")
    }
    return self
  }
}

// MARK: - EXPECT ARGS+ RESOLVER

extension Resolver {
  @discardableResult
  public func register<T, R: ResolverProtocol>(
    _ scope: Scope = .single,
    expect object: T.Type = T.self,
    closure: @escaping BoxClosureNoArgR<T, R>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    coreInstance.setBox(dependencyId, box: Box<T, R, Void, Void, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .noargsR(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId)")
    return self
  }
  
  @discardableResult
  public func register<T, R: ResolverProtocol, A>(
    _ scope: Scope = .single,
    expect object: T.Type = T.self,
    arg1: A.Type,
    closure: @escaping BoxClosure1ArgR<T, R, A>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    coreInstance.setBox(dependencyId, box: Box<T?, R, A, Void, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .arg1R(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, R: ResolverProtocol, A, B>(
    scope: Scope = .single,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    closure: @escaping BoxClosure2ArgR<T, R, A, B>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    let box = coreInstance.setBox(dependencyId, box: Box<T?, R, A, B, Void, Void>(
      resolver: self,
      scope: scope,
      closure: .args2R(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId) with expected args \(box.stringArgs)")
    return self
  }
  
  @discardableResult
  public func register<T, R: ResolverProtocol, A, B, C>(
    scope: Scope = .single,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    closure: @escaping BoxClosure3ArgR<T, R, A, B, C>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    coreInstance.setBox(dependencyId, box: Box<T, R, A, B, C, Void>(
      resolver: self,
      scope: scope,
      closure: .args3R(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId) with expected argument \(arg1)")
    return self
  }
  
  @discardableResult
  public func register<T, R: ResolverProtocol, A, B, C, D>(
    scope: Scope = .single,
    expect object: T.Type = T.self,
    arg1: A.Type,
    arg2: B.Type,
    arg3: C.Type,
    arg4: D.Type,
    closure: @escaping BoxClosure4ArgR<T, R, A, B, C, D>
  ) -> Self {
    let dependencyId = getDependencyId(object.self).clean()
    coreInstance.setBox(dependencyId, box: Box<T, R, A, B, C, D>(
      resolver: self,
      scope: scope,
      closure: .args4R(closure)
    ))
    logger(.info, "\(resolverId) - registered \(dependencyId) with expected argument \(arg1)")
    return self
  }
}

// MARK: - EXPECT+ ARGS+ RESOLVER
