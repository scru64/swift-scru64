import XCTest

@testable import Scru64

func assertConsecutive(_ first: Scru64Id, _ second: Scru64Id) throws {
  XCTAssertLessThan(first, second)
  if first.timestamp == second.timestamp {
    XCTAssertEqual(first.nodeCtr + 1, second.nodeCtr)
  } else {
    XCTAssertEqual(first.timestamp + 1, second.timestamp)
  }
}

final class Scru64GeneratorTests: XCTestCase {
  /// Normally generates monotonic IDs or resets state upon significant rollback.
  func testGenerateOrReset() throws {
    let nLoops = 64
    let allowance: UInt64 = 10_000

    for e in exampleNodeSpecs {
      let counterSize = 24 - e.nodeIdSize
      let nodeSpec = try Scru64NodeSpec(nodeId: e.nodeId, nodeIdSize: e.nodeIdSize)
      let g = Scru64Generator(nodeSpec)

      // happy path
      var ts: UInt64 = 1_577_836_800_000  // 2020-01-01
      var prev = g.generateOrResetCore(unixTsMs: ts, rollbackAllowance: allowance)
      for _ in 0..<nLoops {
        ts += 16
        let curr = g.generateOrResetCore(unixTsMs: ts, rollbackAllowance: allowance)
        try assertConsecutive(prev, curr)
        XCTAssertLessThan(curr.timestamp - (ts >> 8), allowance >> 8)
        XCTAssertEqual(curr.nodeCtr >> counterSize, e.nodeId)

        prev = curr
      }

      // keep monotonic order under mildly decreasing timestamps
      ts += allowance * 16
      prev = g.generateOrResetCore(unixTsMs: ts, rollbackAllowance: allowance)
      for _ in 0..<nLoops {
        ts -= 16
        let curr = g.generateOrResetCore(unixTsMs: ts, rollbackAllowance: allowance)
        try assertConsecutive(prev, curr)
        XCTAssertLessThan(curr.timestamp - (ts >> 8), allowance >> 8)
        XCTAssertEqual(curr.nodeCtr >> counterSize, e.nodeId)

        prev = curr
      }

      // reset state with significantly decreasing timestamps
      ts += allowance * 16
      prev = g.generateOrResetCore(unixTsMs: ts, rollbackAllowance: allowance)
      for _ in 0..<nLoops {
        ts -= allowance + 0x100
        let curr = g.generateOrResetCore(unixTsMs: ts, rollbackAllowance: allowance)
        XCTAssertGreaterThan(prev, curr)
        XCTAssertLessThan(curr.timestamp - (ts >> 8), allowance >> 8)
        XCTAssertEqual(curr.nodeCtr >> counterSize, e.nodeId)

        prev = curr
      }
    }
  }

  /// Normally generates monotonic IDs or aborts upon significant rollback.
  func testGenerateOrAbort() throws {
    let nLoops = 64
    let allowance: UInt64 = 10_000

    for e in exampleNodeSpecs {
      let counterSize = 24 - e.nodeIdSize
      let nodeSpec = try Scru64NodeSpec(nodeId: e.nodeId, nodeIdSize: e.nodeIdSize)
      let g = Scru64Generator(nodeSpec)

      // happy path
      var ts: UInt64 = 1_577_836_800_000  // 2020-01-01
      var prev = g.generateOrAbortCore(unixTsMs: ts, rollbackAllowance: allowance)
      XCTAssertNotNil(prev)
      for _ in 0..<nLoops {
        ts += 16
        let curr = g.generateOrAbortCore(unixTsMs: ts, rollbackAllowance: allowance)
        XCTAssertNotNil(curr)
        try assertConsecutive(prev!, curr!)
        XCTAssertLessThan(curr!.timestamp - (ts >> 8), allowance >> 8)
        XCTAssertEqual(curr!.nodeCtr >> counterSize, e.nodeId)

        prev = curr
      }

      // keep monotonic order under mildly decreasing timestamps
      ts += allowance * 16
      prev = g.generateOrAbortCore(unixTsMs: ts, rollbackAllowance: allowance)
      XCTAssertNotNil(prev)
      for _ in 0..<nLoops {
        ts -= 16
        let curr = g.generateOrAbortCore(unixTsMs: ts, rollbackAllowance: allowance)
        XCTAssertNotNil(curr)
        try assertConsecutive(prev!, curr!)
        XCTAssertLessThan(curr!.timestamp - (ts >> 8), allowance >> 8)
        XCTAssertEqual(curr!.nodeCtr >> counterSize, e.nodeId)

        prev = curr
      }

      // abort with significantly decreasing timestamps
      ts += allowance * 16
      prev = g.generateOrAbortCore(unixTsMs: ts, rollbackAllowance: allowance)
      XCTAssertNotNil(prev)
      ts -= allowance + 0x100
      for _ in 0..<nLoops {
        ts -= 16
        let curr = g.generateOrAbortCore(unixTsMs: ts, rollbackAllowance: allowance)
        XCTAssertNil(curr)
      }
    }
  }

  /// Embeds up-to-date timestamp.
  func testClockIntegration() throws {
    for e in exampleNodeSpecs {
      let nodeSpec = try Scru64NodeSpec(nodeId: e.nodeId, nodeIdSize: e.nodeIdSize)
      let g = Scru64Generator(nodeSpec)

      var tsNow = UInt64(Date().timeIntervalSince1970 * 1000) >> 8
      let x = g.generate()
      XCTAssertNotNil(x)
      XCTAssertLessThanOrEqual(x!.timestamp - tsNow, 1)

      tsNow = UInt64(Date().timeIntervalSince1970 * 1000) >> 8
      var y = g.generateOrReset()
      XCTAssertLessThanOrEqual(y.timestamp - tsNow, 1)

      tsNow = UInt64(Date().timeIntervalSince1970 * 1000) >> 8
      y = g.generateOrSleep()
      XCTAssertLessThanOrEqual(y.timestamp - tsNow, 1)
    }
  }
}
