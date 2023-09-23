import Foundation

/// Represents a SCRU64 ID generator.
///
/// The generator comes with several different methods that generate a SCRU64 ID:
///
/// | Flavor                                               | Timestamp | Thread- | On big clock rewind |
/// | ---------------------------------------------------- | --------- | ------- | ------------------- |
/// | ``generate()``                                       | Now       | Safe    | Returns `nil`       |
/// | ``generateOrReset()``                                | Now       | Safe    | Resets generator    |
/// | ``generateOrSleep()``                                | Now       | Safe    | Sleeps (blocking)   |
/// | ``generateOrAwait()``                                | Now       | Safe    | Sleeps (async)      |
/// | ``generateOrAbortCore(unixTsMs:rollbackAllowance:)`` | Argument  | Unsafe  | Returns `nil`       |
/// | ``generateOrResetCore(unixTsMs:rollbackAllowance:)`` | Argument  | Unsafe  | Resets generator    |
///
/// All of these methods return a monotonically increasing ID by reusing the previous `timestamp`
/// even if the one provided is smaller than the immediately preceding ID's, unless such a clock
/// rollback is considered significant (by default, approx. 10 seconds). A clock rollback may also
/// be detected when a generator has generated too many IDs within a certain unit of time, because
/// this implementation increments the previous `timestamp` when `counter` reaches the limit to
/// continue instant monotonic generation. When a significant clock rollback is detected:
///
/// 1.  `generate` (OrAbort) methods abort and return `nil` immediately.
/// 2.  `OrReset` variants reset the generator and return a new ID based on the given `timestamp`,
///     breaking the increasing order of IDs.
/// 3.  `OrSleep` and `OrAwait` methods sleep and wait for the next timestamp tick.
///
/// The `Core` functions offer low-level thread-unsafe primitives to customize the behavior.
public class Scru64Generator<C: Scru64CounterMode> {
  var prev: Scru64Id
  let counterSize: UInt8
  var counterMode: C
  let lock = NSLock()

  /// Creates a new generator with the given node configuration.
  public convenience init(_ nodeSpec: Scru64NodeSpec) where C == Scru64CounterModeDefault {
    if nodeSpec.nodeIdSize < 20 {
      self.init(nodeSpec, counterMode: Scru64CounterModeDefault(overflowGuardSize: 0))
    } else {
      // reserve one overflow guard bit if `counterSize` is very small
      self.init(nodeSpec, counterMode: Scru64CounterModeDefault(overflowGuardSize: 1))
    }
  }

  /// Creates a new generator with the given node configuration and counter initialization mode.
  public init(_ nodeSpec: Scru64NodeSpec, counterMode: C) {
    prev = nodeSpec.nodePrevRaw
    counterSize = nodeCtrSize - nodeSpec.nodeIdSize
    self.counterMode = counterMode
  }

  /// Returns the `nodeId` of the generator.
  public var nodeId: UInt32 { prev.nodeCtr >> counterSize }

  /// Returns the size in bits of the `nodeId` adopted by the generator.
  public var nodeIdSize: UInt8 { nodeCtrSize - counterSize }

  /// Returns the node configuration specifier describing the generator state.
  public var nodeSpec: Scru64NodeSpec {
    try! Scru64NodeSpec(nodePrev: prev, nodeIdSize: nodeIdSize)
  }

  /// Calculates the combined `nodeCtr` field value for the next `timestamp` tick.
  func renewNodeCtr(timestamp: UInt64) -> UInt32 {
    let nodeId = self.nodeId
    let context = Scru64CounterModeRenewContext(timestamp: timestamp, nodeId: nodeId)
    let counter = counterMode.renew(counterSize: counterSize, context: context)
    precondition(counter < (1 << counterSize), "illegal `CounterMode` implementation")
    return (nodeId << counterSize) | counter
  }

  /// Generates a new SCRU64 ID object from the current `timestamp`, or returns `nil` upon
  /// significant timestamp rollback.
  ///
  /// See the ``Scru64Generator`` type documentation for the description.
  public func generate() -> Scru64Id? {
    lock.lock()
    defer { lock.unlock() }
    return generateOrAbortCore(
      unixTsMs: UInt64(Date().timeIntervalSince1970 * 1_000), rollbackAllowance: 10_000)
  }

  /// Generates a new SCRU64 ID object from the current `timestamp`, or resets the generator upon
  /// significant timestamp rollback.
  ///
  /// See the ``Scru64Generator`` type documentation for the description.
  ///
  /// Note that this mode of generation is not recommended because rewinding `timestamp` without
  /// changing `nodeId` considerably increases the risk of duplicate results.
  public func generateOrReset() -> Scru64Id {
    lock.lock()
    defer { lock.unlock() }
    return generateOrResetCore(
      unixTsMs: UInt64(Date().timeIntervalSince1970 * 1_000), rollbackAllowance: 10_000)
  }

  /// Returns a new SCRU64 ID object, or synchronously sleeps and waits for one if not immediately
  /// available.
  ///
  /// See the ``Scru64Generator`` type documentation for the description.
  ///
  /// - Warning: This method uses the blocking `Thread.sleep` to wait for the next `timestamp` tick.
  ///   Use ``generateOrAwait()`` where possible.
  public func generateOrSleep() -> Scru64Id {
    while true {
      if let value = generate() {
        return value
      } else {
        Thread.sleep(forTimeInterval: 64 / 1000)
      }
    }
  }

  /// Returns a new SCRU64 ID object, or asynchronously sleeps and waits for one if not immediately
  /// available.
  ///
  /// See the ``Scru64Generator`` type documentation for the description.
  @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)
  public func generateOrAwait() async -> Scru64Id {
    while true {
      if let value = generate() {
        return value
      } else {
        do {
          try await Task.sleep(nanoseconds: 64 * 1000 * 1000)
        } catch is CancellationError {
          // ignore cancellation signals because this method is supposed to return in a short period
          // of time up to 256 milliseconds as long as the clock is working properly
        } catch {
          fatalError("unreachable")
        }
      }
    }
  }

  /// Generates a new SCRU64 ID object from a Unix timestamp in milliseconds, or resets the
  /// generator upon significant timestamp rollback.
  ///
  /// See the ``Scru64Generator`` type documentation for the description.
  ///
  /// Note that this mode of generation is not recommended because rewinding `timestamp` without
  /// changing `nodeId` considerably increases the risk of duplicate results.
  ///
  /// The `rollbackAllowance` parameter specifies the amount of `unixTsMs` rollback that is
  /// considered significant. A suggested value is `10_000` (milliseconds).
  ///
  /// - Warning: Unlike ``generateOrReset()``, this method is NOT thread-safe. The generator object
  ///   should be protected from concurrent accesses using a mutex or other synchronization
  ///   mechanism to avoid race conditions.
  /// - Precondition: `unixTsMs` mut be a positive integer within the valid range.
  public func generateOrResetCore(unixTsMs: UInt64, rollbackAllowance: UInt64) -> Scru64Id {
    if let value = generateOrAbortCore(unixTsMs: unixTsMs, rollbackAllowance: rollbackAllowance) {
      return value
    } else {
      // reset state and resume
      let timestamp = unixTsMs >> 8
      prev = try! Scru64Id(timestamp: timestamp, nodeCtr: renewNodeCtr(timestamp: timestamp))
      return prev
    }
  }

  /// Generates a new SCRU64 ID object from a Unix timestamp in milliseconds, or returns `nil` upon
  /// significant timestamp rollback.
  ///
  /// See the ``Scru64Generator`` type documentation for the description.
  ///
  /// The `rollbackAllowance` parameter specifies the amount of `unixTsMs` rollback that is
  /// considered significant. A suggested value is `10_000` (milliseconds).
  ///
  /// - Warning: Unlike ``generate()``, this method is NOT thread-safe. The generator object should
  ///   be protected from concurrent accesses using a mutex or other synchronization mechanism to
  ///   avoid race conditions.
  /// - Precondition: `unixTsMs` mut be a positive integer within the valid range.
  public func generateOrAbortCore(unixTsMs: UInt64, rollbackAllowance: UInt64) -> Scru64Id? {
    let timestamp = unixTsMs >> 8
    let allowance = rollbackAllowance >> 8
    precondition(0 < timestamp && timestamp <= maxTimestamp, "`timestamp` out of range")
    precondition(allowance < (1 << 40), "`rollbackAllowance` out of reasonable range")

    let prevTimestamp = prev.timestamp
    if timestamp > prevTimestamp {
      prev = try! Scru64Id(timestamp: timestamp, nodeCtr: renewNodeCtr(timestamp: timestamp))
    } else if timestamp + allowance >= prevTimestamp {
      // go on with previous timestamp if new one is not much smaller
      let prevNodeCtr = prev.nodeCtr
      let counterMask = UInt32(1) << counterSize - 1
      if (prevNodeCtr & counterMask) < counterMask {
        prev = try! Scru64Id(timestamp: prevTimestamp, nodeCtr: prevNodeCtr + 1)
      } else {
        // increment timestamp at counter overflow
        do {
          prev = try Scru64Id(
            timestamp: prevTimestamp + 1, nodeCtr: renewNodeCtr(timestamp: prevTimestamp + 1))
        } catch {
          fatalError("`timestamp` and `counter` reached max; no more ID available")
        }
      }
    } else {
      // abort if clock went backwards to unbearable extent
      return nil
    }
    return prev
  }
}
