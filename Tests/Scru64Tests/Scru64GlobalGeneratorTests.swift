import XCTest

@testable import Scru64

final class Scru64GlobalGeneratorTests: XCTestCase {
  override class func setUp() {
    // call libc function
    setenv("SCRU64_NODE_SPEC", "42/8", 1)
  }

  /// Reads configuration from environment var.
  func testDefaultInitializer() throws {
    XCTAssertEqual(Scru64GlobalGenerator.nodeId, 42)
    XCTAssertEqual(Scru64GlobalGenerator.nodeIdSize, 8)
  }

  /// Generates 100k monotonically increasing IDs
  func testNewStringSync() throws {
    var prev = scru64StringSync()
    for _ in 0..<100_000 {
      let curr = scru64StringSync()
      XCTAssertLessThan(prev, curr)
      prev = curr
    }
  }

  /// Generates 100k monotonically increasing IDs
  @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)
  func testNewStringAsync() async throws {
    var prev = await scru64String()
    for _ in 0..<100_000 {
      let curr = await scru64String()
      XCTAssertLessThan(prev, curr)
      prev = curr
    }
  }
}
