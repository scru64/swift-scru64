import XCTest

@testable import Scru64

final class Scru64NodeSpecTests: XCTestCase {
  /// Initializes with node ID and size pair and node spec string.
  func testConstructor() throws {
    for e in exampleNodeSpecs {
      let nodePrev = try Scru64Id(e.nodePrev)

      let withNodePrev = try Scru64NodeSpec(nodePrev: nodePrev, nodeIdSize: e.nodeIdSize)
      XCTAssertEqual(withNodePrev.nodeId, e.nodeId)
      XCTAssertEqual(withNodePrev.nodeIdSize, e.nodeIdSize)
      if let p = withNodePrev.nodePrev {
        XCTAssertEqual(p, nodePrev)
      }
      XCTAssertEqual(withNodePrev.nodePrevRaw, nodePrev)
      XCTAssertEqual(withNodePrev.description, e.canonical)

      let withNodeId = try Scru64NodeSpec(nodeId: e.nodeId, nodeIdSize: e.nodeIdSize)
      XCTAssertEqual(withNodeId.nodeId, e.nodeId)
      XCTAssertEqual(withNodeId.nodeIdSize, e.nodeIdSize)
      XCTAssertNil(withNodeId.nodePrev)
      if e.specType.hasSuffix("_node_id") {
        XCTAssertEqual(withNodeId.nodePrevRaw, nodePrev)
        XCTAssertEqual(withNodeId.description, e.canonical)
      }

      let parsed = try Scru64NodeSpec(parsing: e.nodeSpec)
      XCTAssertEqual(parsed.nodeId, e.nodeId)
      XCTAssertEqual(parsed.nodeIdSize, e.nodeIdSize)
      if let p = parsed.nodePrev {
        XCTAssertEqual(p, nodePrev)
      }
      XCTAssertEqual(parsed.nodePrevRaw, nodePrev)
      XCTAssertEqual(parsed.description, e.canonical)
    }
  }

  /// Fails to initialize with invalid node spec string.
  func testConstructorError() throws {
    let cases = [
      "",
      "42",
      "/8",
      "42/",
      " 42/8",
      "42/8 ",
      " 42/8 ",
      "42 / 8",
      "+42/8",
      "42/+8",
      "-42/8",
      "42/-8",
      "ab/8",
      "1/2/3",
      "0/0",
      "0/24",
      "8/1",
      "1024/8",
      "0000000000001/8",
      "1/0016",
      "42/800",
    ]

    for e in cases {
      XCTAssertNil(Scru64NodeSpec(e))
      XCTAssertThrowsError(try Scru64NodeSpec(parsing: e))
    }
  }

  /// Supports serialization and deserialization.
  func testSerDe() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    for e in exampleNodeSpecs {
      let x = try Scru64NodeSpec(nodePrev: try Scru64Id(e.nodePrev), nodeIdSize: e.nodeIdSize)
      let expected = try encoder.encode(e.canonical)

      XCTAssertEqual(try encoder.encode(x), expected)
      XCTAssertEqual(try decoder.decode(Scru64NodeSpec.self, from: expected), x)
    }
  }
}
