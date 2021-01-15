
import Foundation

internal let null: Void? = Void?.none

public typealias BoxClosureNoArg<T> = () throws -> T
public typealias BoxClosure1Arg<T, A> = (A) throws -> T
public typealias BoxClosure2Arg<T, A, B> = (A, B) throws -> T
public typealias BoxClosure3Arg<T, A, B, C> = (A, B, C) throws -> T
public typealias BoxClosure4Arg<T, A, B, C, D> = (A, B, C, D) throws -> T
public typealias BoxClosure5Arg<T, A, B, C, D, E> = (A, B, C, D, E) throws -> T
public typealias BoxClosure6Arg<T, A, B, C, D, E, F> = (A, B, C, D, E, F) throws -> T
public typealias BoxClosure7Arg<T, A, B, C, D, E, F, G> = (A, B, C, D, E, F, G) throws -> T
public typealias BoxClosure8Arg<T, A, B, C, D, E, F, G, H> = (A, B, C, D, E, F, G, H) throws -> T
public typealias BoxClosure9Arg<T, A, B, C, D, E, F, G, H, I> = (A, B, C, D, E, F, G, H, I) throws -> T
public typealias BoxClosure10Arg<T, A, B, C, D, E, F, G, H, I, J> = (A, B, C, D, E, F, G, H, I, J) throws -> T

public typealias BoxClosureNoArgR<T, R: ResolverProtocol> = (R) throws -> T
public typealias BoxClosure1ArgR<T, R: ResolverProtocol, A> = (R, A) throws -> T
public typealias BoxClosure2ArgR<T, R: ResolverProtocol, A, B> = (R, A, B) throws -> T
public typealias BoxClosure3ArgR<T, R: ResolverProtocol, A, B, C> = (R, A, B, C) throws -> T
public typealias BoxClosure4ArgR<T, R: ResolverProtocol, A, B, C, D> = (R, A, B, C, D) throws -> T
