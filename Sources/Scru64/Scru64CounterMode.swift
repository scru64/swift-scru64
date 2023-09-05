/// A protocol to customize the initial counter value for each new `timestamp`.
///
/// ``Scru64Generator`` calls ``renew(counterSize:context:)`` to obtain the initial counter value
/// when the `timestamp` field has changed since the immediately preceding ID. Types implementing
/// this interface may apply their respective logic to calculate the initial counter value.
public protocol Scru64CounterMode {
  /// Returns the next initial counter value of `counterSize` bits.
  ///
  /// ``Scru64Generator`` passes the `counterSize` (from 1 to 23) and other context information that
  /// may be useful for counter renewal. The returned value must be within the range of
  /// `counterSize`-bit unsigned integer.
  mutating func renew(counterSize: UInt8, context: Scru64CounterModeRenewContext) -> UInt32
}

/// Represents the context information provided by ``Scru64Generator`` to
/// `CounterMode.renew(counterSize:context:)`.
public struct Scru64CounterModeRenewContext {
  /// The `timestamp` value for the new counter.
  public let timestamp: UInt64

  /// The `nodeId` of the generator.
  public let nodeId: UInt32
}

/// The default "initialize a portion counter" strategy.
///
/// With this strategy, the counter is reset to a random number for each new `timestamp` tick, but
/// some specified leading bits are set to zero to reserve space as the counter overflow guard.
public struct Scru64CounterModeDefault: Scru64CounterMode {
  let overflowGuardSize: UInt8

  /// Creates a new instance with the size (in bits) of overflow guard bits.
  public init(overflowGuardSize: UInt8) {
    self.overflowGuardSize = overflowGuardSize
  }

  /// Returns the next initial counter value of `counterSize` bits.
  public mutating func renew(counterSize: UInt8, context: Scru64CounterModeRenewContext) -> UInt32 {
    if overflowGuardSize < counterSize {
      return UInt32.random(in: 0..<(1 << (counterSize - overflowGuardSize)))
    } else {
      return 0
    }
  }
}
