import XCTest

@testable import Scru64

final class Scru64IdTests: XCTestCase {
  /// Supports equality comparison.
  func testEq() throws {
    var prev = try Scru64Id(exampleIds.last!.num)
    for e in exampleIds {
      let curr = try Scru64Id(e.num)
      let twin = try Scru64Id(e.num)

      XCTAssertEqual(curr, twin)
      XCTAssertEqual(twin, curr)
      XCTAssertEqual(curr.num, twin.num)
      XCTAssertEqual(curr.description, twin.description)
      XCTAssertEqual(curr.timestamp, twin.timestamp)
      XCTAssertEqual(curr.nodeCtr, twin.nodeCtr)

      XCTAssertNotEqual(curr, prev)
      XCTAssertNotEqual(prev, curr)
      XCTAssertNotEqual(curr.num, prev.num)
      XCTAssertNotEqual(curr.description, prev.description)
      XCTAssert((curr.timestamp != prev.timestamp) || (curr.nodeCtr != prev.nodeCtr))

      prev = curr
    }
  }

  /// Supports ordering comparison.
  func testOrd() throws {
    let cases = exampleIds.sorted { $0.num < $1.num }

    var prev = try Scru64Id(cases[0].num)
    for e in cases[1...] {
      let curr = try Scru64Id(e.num)

      XCTAssertLessThan(prev, curr)
      XCTAssertLessThanOrEqual(prev, curr)

      XCTAssertGreaterThan(curr, prev)
      XCTAssertGreaterThanOrEqual(curr, prev)

      XCTAssertLessThan(prev.num, curr.num)
      XCTAssertLessThan(prev.description, curr.description)

      prev = curr
    }
  }

  /// Converts to various types.
  func testConvertTo() throws {
    for e in exampleIds {
      let x = try Scru64Id(e.num)

      XCTAssertEqual(x.num, e.num)
      XCTAssertEqual(Int64(x.num), Int64(e.num))
      XCTAssertEqual(x.description, e.text)
      XCTAssertEqual(String(x), e.text)
      XCTAssertEqual(x.timestamp, e.timestamp)
      XCTAssertEqual(x.nodeCtr, e.nodeCtr)
    }
  }

  /// Converts from various types.
  func testConvertFrom() throws {
    for e in exampleIds {
      let x = try Scru64Id(e.num)

      XCTAssertEqual(Scru64Id(e.text)!, x)
      XCTAssertEqual(Scru64Id(e.text.uppercased())!, x)
      XCTAssertEqual(try Scru64Id(parsing: e.text), x)
      XCTAssertEqual(try Scru64Id(parsing: e.text.uppercased()), x)
      XCTAssertEqual(try Scru64Id(timestamp: e.timestamp, nodeCtr: e.nodeCtr), x)
    }
  }

  /// Rejects integer out of valid range.
  func testFromIntError() throws {
    XCTAssertThrowsError(try Scru64Id(4_738_381_338_321_616_896))
    XCTAssertThrowsError(try Scru64Id(0xffff_ffff_ffff_ffff))
  }

  /// Fails to parse invalid textual representations.
  func testParseError() throws {
    let cases = [
      "",
      " 0u3wrp5g81jx",
      "0u3wrp5g81jy ",
      " 0u3wrp5g81jz ",
      "+0u3wrp5g81k0",
      "-0u3wrp5g81k1",
      "+u3wrp5q7ta5",
      "-u3wrp5q7ta6",
      "0u3w_p5q7ta7",
      "0u3wrp5-7ta8",
      "0u3wrp5q7t 9",
    ]

    for e in cases {
      XCTAssertNil(Scru64Id(e))
    }
  }

  /// Rejects `MAX + 1` even if passed as pair of fields.
  func testFromPartsError() throws {
    let max: UInt64 = 4_738_381_338_321_616_895
    XCTAssertThrowsError(try Scru64Id(timestamp: max >> 24, nodeCtr: UInt32(max & 0xff_ffff) + 1))
    XCTAssertThrowsError(try Scru64Id(timestamp: (max >> 24) + 1, nodeCtr: 0))
  }

  /// Supports serialization and deserialization.
  func testSerDe() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    for e in exampleIds {
      let x = try Scru64Id(e.num)
      let strExpected = try encoder.encode(e.text)
      let numExpected = try encoder.encode(e.num)

      XCTAssertEqual(try encoder.encode(x), strExpected)
      XCTAssertEqual(try decoder.decode(Scru64Id.self, from: strExpected), x)
      XCTAssertEqual(try decoder.decode(Scru64Id.self, from: numExpected), x)
    }
  }
}
