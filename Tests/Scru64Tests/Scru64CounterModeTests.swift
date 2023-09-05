import XCTest

@testable import Scru64

final class Scru64CounterModeTests: XCTestCase {
  /// `DefaultCounterMode` returns random numbers, setting the leading guard bits to zero.
  ///
  /// This case includes statistical tests for the random number generator and thus may fail at a
  /// certain low probability.
  @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)
  func testDefaultCounterMode() async throws {
    let nLoops = 256

    // set margin based on binom dist 99.999999% confidence interval
    let margin = 5.730729 * (0.5 * 0.5 / Double(nLoops)).squareRoot()

    let context = Scru64CounterModeRenewContext(timestamp: 0x0123_4567_89ab, nodeId: 0)
    let routine = { counterSize in
      for overflowGuardSize in 0..<nodeCtrSize {
        // count number of set bits by bit position (from LSB to MSB)
        var countsByPos = [UInt32](repeating: 0, count: Int(nodeCtrSize))

        var c: Scru64CounterMode = Scru64CounterModeDefault(overflowGuardSize: overflowGuardSize)
        for _ in 0..<nLoops {
          var n = c.renew(counterSize: counterSize, context: context)
          for j in countsByPos.indices {
            countsByPos[j] += n & 1
            n >>= 1
          }
          XCTAssertEqual(n, 0)
        }

        let filled = max(0, Int(counterSize) - Int(overflowGuardSize))
        for e in countsByPos[..<filled] {
          XCTAssertLessThan(abs(Double(e) / Double(nLoops) - 0.5), margin)
        }
        for e in countsByPos[filled...] {
          XCTAssertEqual(e, 0)
        }
      }
    }

    // run concurrently because the routine is weirdly slow under Debug build
    await withTaskGroup(of: Void.self) { group in
      for counterSize in 1..<nodeCtrSize {
        group.addTask { routine(counterSize) }
      }
    }
  }
}
