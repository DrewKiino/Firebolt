
import XCTest
@testable import SwiftResolver

final class SwiftResolverTests: XCTestCase {
  private let resolver = SwiftResolver()

  func basicResolution(){
    let new = ClassA() 
    do { try resolver.register { new } } catch {}
    let classA: ClassA = get()
     XCTAssertEqual(new.id, classA.id)
  }

  static var allTests = [
      ("basicResolution", basicResolution),
  ]
}
